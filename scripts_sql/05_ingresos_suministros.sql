-- Prepara el registro de nuevos ingresos.


--TABLA DE INGRESOS

CREATE TABLE ingreso_suministro (
    cod_ingreso VARCHAR(20) NOT NULL,
    cod_almacen VARCHAR(20) NOT NULL,
    cod_suministro VARCHAR(20) NOT NULL,

    fecha_hora_registro TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    cantidad_ingresada NUMERIC(12,3) NOT NULL,
    origen VARCHAR(150) NOT NULL,
    referencia VARCHAR(100),
    observacion VARCHAR(500),

    CONSTRAINT pk_ingreso_suministro
        PRIMARY KEY (cod_ingreso),

    CONSTRAINT fk_ingreso_almacen
        FOREIGN KEY (cod_almacen)
        REFERENCES almacen (cod_almacen),

    CONSTRAINT fk_ingreso_suministro
        FOREIGN KEY (cod_suministro)
        REFERENCES suministro (cod_suministro),

    CONSTRAINT ck_ingreso_codigo
        CHECK (BTRIM(cod_ingreso) <> ''),

    CONSTRAINT ck_ingreso_cantidad
        CHECK (
            cantidad_ingresada > 0
            AND cantidad_ingresada < 1000000000
        ),

    CONSTRAINT ck_ingreso_origen
        CHECK (BTRIM(origen) <> '')
);

-- ÍNDICES PARA CONSULTAR LOS INGRESOS

CREATE INDEX idx_ingreso_almacen_fecha
ON ingreso_suministro (
    cod_almacen,
    fecha_hora_registro DESC
);


CREATE INDEX idx_ingreso_suministro_fecha
ON ingreso_suministro (
    cod_suministro,
    fecha_hora_registro DESC
);


-- La función:

CREATE OR REPLACE FUNCTION registrar_ingreso_suministro(
    p_cod_ingreso VARCHAR,
    p_cod_almacen VARCHAR,
    p_cod_suministro VARCHAR,
    p_cantidad NUMERIC,
    p_origen VARCHAR,
    p_referencia VARCHAR DEFAULT NULL,
    p_observacion VARCHAR DEFAULT NULL
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock_resultante NUMERIC(12,3);
BEGIN
    -- Validar el código del ingreso.
    IF p_cod_ingreso IS NULL
       OR BTRIM(p_cod_ingreso) = '' THEN
        RAISE EXCEPTION
            'Debe indicar el codigo del ingreso.';
    END IF;

    -- Validar el almacén.
    IF p_cod_almacen IS NULL
       OR BTRIM(p_cod_almacen) = '' THEN
        RAISE EXCEPTION
            'Debe indicar el codigo del almacen.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM almacen
        WHERE cod_almacen = p_cod_almacen
    ) THEN
        RAISE EXCEPTION
            'El almacen % no existe.',
            p_cod_almacen;
    END IF;

    -- Validar el suministro.
    IF p_cod_suministro IS NULL
       OR BTRIM(p_cod_suministro) = '' THEN
        RAISE EXCEPTION
            'Debe indicar el codigo del suministro.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM suministro
        WHERE cod_suministro = p_cod_suministro
    ) THEN
        RAISE EXCEPTION
            'El suministro % no existe.',
            p_cod_suministro;
    END IF;

    -- Validar la cantidad y el rango permitido.
    IF p_cantidad IS NULL
       OR p_cantidad <= 0
       OR p_cantidad >= 1000000000 THEN
        RAISE EXCEPTION
            'La cantidad debe ser positiva y menor que 1000000000.';
    END IF;

    -- Evitar redondear silenciosamente cantidades
    -- que superen los tres decimales del modelo.
    IF p_cantidad <> ROUND(p_cantidad, 3) THEN
        RAISE EXCEPTION
            'La cantidad admite como maximo tres decimales.';
    END IF;

    -- Validar el origen del ingreso.
    IF p_origen IS NULL
       OR BTRIM(p_origen) = '' THEN
        RAISE EXCEPTION
            'Debe indicar el origen del ingreso.';
    END IF;

    -- Registrar el movimiento.
    -- La clave primaria impide repetir el código de ingreso.
    INSERT INTO ingreso_suministro (
        cod_ingreso,
        cod_almacen,
        cod_suministro,
        cantidad_ingresada,
        origen,
        referencia,
        observacion
    )
    VALUES (
        p_cod_ingreso,
        p_cod_almacen,
        p_cod_suministro,
        p_cantidad,
        BTRIM(p_origen),
        p_referencia,
        p_observacion
    );

    -- Si no existe el stock de esa combinación, lo crea.
    -- Si ya existe, suma el nuevo ingreso al saldo actual.
    INSERT INTO existencia (
        cod_almacen,
        cod_suministro,
        cantidad_disponible
    )
    VALUES (
        p_cod_almacen,
        p_cod_suministro,
        p_cantidad
    )
    ON CONFLICT (cod_almacen, cod_suministro)
    DO UPDATE
    SET cantidad_disponible =
        existencia.cantidad_disponible
        + EXCLUDED.cantidad_disponible
    RETURNING cantidad_disponible
    INTO v_stock_resultante;

    RETURN v_stock_resultante;
END;
$$;


CREATE OR REPLACE VIEW vista_historial_ingresos AS
SELECT
    i.cod_ingreso,
    i.fecha_hora_registro,
    a.cod_almacen,
    a.nombre AS almacen,
    s.cod_suministro,
    s.nombre AS suministro,
    s.unidad_medida,
    i.cantidad_ingresada,
    i.origen,
    i.referencia,
    i.observacion
FROM ingreso_suministro i
JOIN almacen a
    ON i.cod_almacen = a.cod_almacen
JOIN suministro s
    ON i.cod_suministro = s.cod_suministro;



