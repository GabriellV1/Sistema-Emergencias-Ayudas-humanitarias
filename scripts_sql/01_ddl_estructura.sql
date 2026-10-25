-- Creacion de tablas del sistema de emergencias.

CREATE TABLE emergencia (
      cod_emergencia VARCHAR(20) NOT NULL,
      tipo_desastre VARCHAR(60) NOT NULL,
      fecha_hora_ocurrencia TIMESTAMP NOT NULL,
      ubicacion VARCHAR(250) NOT NULL,
      descripcion VARCHAR(1000) NOT NULL,
      estado_atencion VARCHAR(20) NOT NULL DEFAULT 'registrada',

    CONSTRAINT pk_emergencia
          PRIMARY KEY (cod_emergencia)
  );
