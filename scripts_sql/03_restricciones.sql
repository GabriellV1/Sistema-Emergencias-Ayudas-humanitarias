-- SISTEMA DE EMERGENCIAS Y AYUDA HUMANITARIA
-- Relaciones y validaciones de las tablas.
-- Ejecutar después de los archivos 01 y 02.

BEGIN;

-- 1. Cada solicitud pertenece a una emergencia existente.

ALTER TABLE solicitud_ayuda
ADD CONSTRAINT fk_solicitud_emergencia
FOREIGN KEY (cod_emergencia)
REFERENCES emergencia (cod_emergencia);

-- 2. Cada membresía relaciona una persona con una brigada.

ALTER TABLE membresia
ADD CONSTRAINT fk_membresia_personal
FOREIGN KEY (cod_personal)
REFERENCES personal (cod_personal);

ALTER TABLE membresia
ADD CONSTRAINT fk_membresia_brigada
FOREIGN KEY (cod_brigada)
REFERENCES brigada (cod_brigada);
