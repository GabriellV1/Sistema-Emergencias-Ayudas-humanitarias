-- Buscar entregas por solicitud.
CREATE INDEX idx_entrega_solicitud
ON entrega (cod_solicitud);

-- Resumen de entregas.
CREATE OR REPLACE VIEW vista_resumen_entregas AS
SELECT
    e.cod_entrega,
    e.fecha_hora,
    e.cod_solicitud,
    sa.cod_emergencia,
    a.cod_almacen,
    a.nombre AS almacen,
    e.nombre_receptor,
    COUNT(de.cod_suministro) AS tipos_suministro
FROM entrega e
JOIN solicitud_ayuda sa
    ON e.cod_solicitud = sa.cod_solicitud
JOIN almacen a
    ON e.cod_almacen = a.cod_almacen
LEFT JOIN detalle_entrega de
    ON e.cod_entrega = de.cod_entrega
GROUP BY
    e.cod_entrega,
    e.fecha_hora,
    e.cod_solicitud,
    sa.cod_emergencia,
    a.cod_almacen,
    a.nombre,
    e.nombre_receptor;
-- Registrar la entrega y descontar el stock.
CREATE OR REPLACE FUNCTION registrar_entrega(
    p_cod_entrega VARCHAR,
    p_cod_solicitud VARCHAR,
    p_cod_almacen VARCHAR,
    p_nombre_receptor VARCHAR,
    p_detalles JSONB
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_detalle JSONB;
    v_cod_suministro VARCHAR(20);
    v_cantidad NUMERIC;
    v_cantidad_solicitada NUMERIC;
    v_total_entregado NUMERIC;
    v_cantidad_pendiente NUMERIC;
    v_total_detalles INTEGER;
    v_suministros_distintos INTEGER;
BEGIN
    -- Validar los datos generales.
    IF p_cod_entrega IS NULL
       OR BTRIM(p_cod_entrega) = '' THEN
        RAISE EXCEPTION
            'Debe indicar el codigo de la entrega.';
    END IF;

    IF p_cod_solicitud IS NULL
       OR BTRIM(p_cod_solicitud) = '' THEN
        RAISE EXCEPTION
            'Debe indicar el codigo de la solicitud.';
    END IF;

    IF p_cod_almacen IS NULL
       OR BTRIM(p_cod_almacen) = '' THEN
        RAISE EXCEPTION
            'Debe indicar el codigo del almacen.';
    END IF;

    IF p_nombre_receptor IS NULL
       OR BTRIM(p_nombre_receptor) = '' THEN
        RAISE EXCEPTION
            'Debe indicar el nombre del receptor.';
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

    -- Validar la lista de suministros.
    IF p_detalles IS NULL
       OR JSONB_TYPEOF(p_detalles) <> 'array' THEN
        RAISE EXCEPTION
            'Los detalles deben ser una lista JSON.';
    END IF;

    IF JSONB_ARRAY_LENGTH(p_detalles) = 0 THEN
        RAISE EXCEPTION
            'La entrega debe incluir al menos un suministro.';
    END IF;

    FOR v_detalle IN
        SELECT elemento
        FROM JSONB_ARRAY_ELEMENTS(p_detalles)
            AS datos(elemento)
    LOOP
        IF JSONB_TYPEOF(v_detalle)
           IS DISTINCT FROM 'object' THEN
            RAISE EXCEPTION
                'Cada detalle debe ser un objeto JSON.';
        END IF;

        IF JSONB_TYPEOF(v_detalle -> 'cod_suministro')
           IS DISTINCT FROM 'string' THEN
            RAISE EXCEPTION
                'Cada detalle debe incluir un codigo de suministro.';
        END IF;

        IF BTRIM(v_detalle ->> 'cod_suministro') = '' THEN
            RAISE EXCEPTION
                'El codigo del suministro no puede estar vacio.';
        END IF;

        IF JSONB_TYPEOF(v_detalle -> 'cantidad_entregada')
           IS DISTINCT FROM 'number' THEN
            RAISE EXCEPTION
                'La cantidad entregada debe ser numerica.';
        END IF;

        v_cantidad :=
            (v_detalle ->> 'cantidad_entregada')::NUMERIC;

        IF v_cantidad <= 0
           OR v_cantidad >= 1000000000 THEN
            RAISE EXCEPTION
                'La cantidad debe ser positiva y menor que 1000000000.';
        END IF;

        IF v_cantidad <> ROUND(v_cantidad, 3) THEN
            RAISE EXCEPTION
                'La cantidad admite como maximo tres decimales.';
        END IF;
    END LOOP;

    -- Evitar suministros repetidos.
    SELECT
        COUNT(*),
        COUNT(
            DISTINCT BTRIM(elemento ->> 'cod_suministro')
        )
    INTO
        v_total_detalles,
        v_suministros_distintos
    FROM JSONB_ARRAY_ELEMENTS(p_detalles)
        AS datos(elemento);

    IF v_total_detalles <> v_suministros_distintos THEN
        RAISE EXCEPTION
            'No repita un suministro dentro de la misma entrega.';
    END IF;

    -- Bloquear la solicitud mientras se procesa la entrega.
    PERFORM 1
    FROM solicitud_ayuda
    WHERE cod_solicitud = p_cod_solicitud
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'La solicitud % no existe.',
            p_cod_solicitud;
    END IF;

    -- Registrar la cabecera.
    INSERT INTO entrega (
        cod_entrega,
        cod_solicitud,
        cod_almacen,
        fecha_hora,
        nombre_receptor
    )
    VALUES (
        p_cod_entrega,
        p_cod_solicitud,
        p_cod_almacen,
        CURRENT_TIMESTAMP,
        BTRIM(p_nombre_receptor)
    );

    -- Procesar los suministros en orden.
    FOR v_detalle IN
        SELECT elemento
        FROM JSONB_ARRAY_ELEMENTS(p_detalles)
            AS datos(elemento)
        ORDER BY BTRIM(elemento ->> 'cod_suministro')
    LOOP
        v_cod_suministro :=
            BTRIM(v_detalle ->> 'cod_suministro');

        v_cantidad :=
            (v_detalle ->> 'cantidad_entregada')::NUMERIC;

        -- Comprobar que el suministro fue solicitado.
        SELECT ds.cantidad_solicitada
        INTO v_cantidad_solicitada
        FROM detalle_solicitud ds
        WHERE ds.cod_solicitud = p_cod_solicitud
          AND ds.cod_suministro = v_cod_suministro
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION
                'El suministro % no pertenece a la solicitud %.',
                v_cod_suministro,
                p_cod_solicitud;
        END IF;

        -- Calcular lo entregado y lo pendiente.
        SELECT COALESCE(SUM(de.cantidad_entregada), 0)
        INTO v_total_entregado
        FROM entrega e
        JOIN detalle_entrega de
            ON e.cod_entrega = de.cod_entrega
        WHERE e.cod_solicitud = p_cod_solicitud
          AND de.cod_suministro = v_cod_suministro;

        v_cantidad_pendiente :=
            v_cantidad_solicitada - v_total_entregado;

        IF v_cantidad > v_cantidad_pendiente THEN
            RAISE EXCEPTION
                'Cantidad excesiva para %. Pendiente: %, intento: %.',
                v_cod_suministro,
                v_cantidad_pendiente,
                v_cantidad;
        END IF;

        -- Descontar solo si hay stock suficiente.
        UPDATE existencia
        SET cantidad_disponible =
            cantidad_disponible - v_cantidad
        WHERE cod_almacen = p_cod_almacen
          AND cod_suministro = v_cod_suministro
          AND cantidad_disponible >= v_cantidad;

        IF NOT FOUND THEN
            RAISE EXCEPTION
                'No hay existencia registrada o stock suficiente para % en %.',
                v_cod_suministro,
                p_cod_almacen;
        END IF;

        -- Guardar el detalle de la entrega.
        INSERT INTO detalle_entrega (
            cod_entrega,
            cod_suministro,
            cantidad_entregada
        )
        VALUES (
            p_cod_entrega,
            v_cod_suministro,
            v_cantidad
        );
    END LOOP;

    RETURN p_cod_entrega;
END;
$$;
