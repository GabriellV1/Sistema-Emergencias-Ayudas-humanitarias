-- SISTEMA DE EMERGENCIAS Y AYUDA HUMANITARIA
-- Relaciones y validaciones de las tablas.
-- Ejecutar después de los archivos 01 y 02.

BEGIN;

-- 1. Cada solicitud pertenece a una emergencia existente.

ALTER TABLE solicitud_ayuda
ADD CONSTRAINT fk_solicitud_emergencia
FOREIGN KEY (cod_emergencia)
REFERENCES emergencia (cod_emergencia);
