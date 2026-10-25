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

-- Creacion de tablas del sistema de brigada.

CREATE TABLE brigada (
    cod_brigada VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    estado_operativo VARCHAR(25) NOT NULL,

    CONSTRAINT pk_brigada
        PRIMARY KEY (cod_brigada)
);

-- Creacion de tablas del sistema de personal.

CREATE TABLE personal (
    cod_personal VARCHAR(20) NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    documento_identidad VARCHAR(20) NOT NULL,
    telefono VARCHAR(25) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,

    CONSTRAINT pk_personal
        PRIMARY KEY (cod_personal)
);

-- Creacion de tablas del sistema de solicitud de ayuda.

CREATE TABLE solicitud_ayuda (
    cod_solicitud VARCHAR(20) NOT NULL,
    cod_emergencia VARCHAR(20) NOT NULL,
    fecha_hora_registro TIMESTAMP NOT NULL,
    descripcion_necesidad VARCHAR(1000) NOT NULL,
    prioridad VARCHAR(10) NOT NULL,
    estado_atencion VARCHAR(20) NOT NULL DEFAULT 'pendiente',

    CONSTRAINT pk_solicitud_ayuda
        PRIMARY KEY (cod_solicitud)
);



