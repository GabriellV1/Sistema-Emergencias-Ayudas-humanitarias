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




