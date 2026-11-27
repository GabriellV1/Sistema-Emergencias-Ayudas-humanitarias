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

-- 3. Cada asignación relaciona una solicitud con una brigada.

ALTER TABLE asignacion
ADD CONSTRAINT fk_asignacion_solicitud
FOREIGN KEY (cod_solicitud)
REFERENCES solicitud_ayuda (cod_solicitud);

ALTER TABLE asignacion
ADD CONSTRAINT fk_asignacion_brigada
FOREIGN KEY (cod_brigada)
REFERENCES brigada (cod_brigada);

-- 4. Cada detalle indica qué suministro se solicita.

ALTER TABLE detalle_solicitud
ADD CONSTRAINT fk_detalle_solicitud_solicitud
FOREIGN KEY (cod_solicitud)
REFERENCES solicitud_ayuda (cod_solicitud);

ALTER TABLE detalle_solicitud
ADD CONSTRAINT fk_detalle_solicitud_suministro
FOREIGN KEY (cod_suministro)
REFERENCES suministro (cod_suministro);

-- 5. Cada existencia corresponde a un almacén y un suministro.

ALTER TABLE existencia
ADD CONSTRAINT fk_existencia_almacen
FOREIGN KEY (cod_almacen)
REFERENCES almacen (cod_almacen);

ALTER TABLE existencia
ADD CONSTRAINT fk_existencia_suministro
FOREIGN KEY (cod_suministro)
REFERENCES suministro (cod_suministro);

-- 6. Cada entrega corresponde a una solicitud y un almacén.

ALTER TABLE entrega
ADD CONSTRAINT fk_entrega_solicitud
FOREIGN KEY (cod_solicitud)
REFERENCES solicitud_ayuda (cod_solicitud);

ALTER TABLE entrega
ADD CONSTRAINT fk_entrega_almacen
FOREIGN KEY (cod_almacen)
REFERENCES almacen (cod_almacen);


-- 7. Cada detalle indica qué suministro se entregó.

ALTER TABLE detalle_entrega
ADD CONSTRAINT fk_detalle_entrega_entrega
FOREIGN KEY (cod_entrega)
REFERENCES entrega (cod_entrega);

ALTER TABLE detalle_entrega
ADD CONSTRAINT fk_detalle_entrega_suministro
FOREIGN KEY (cod_suministro)
REFERENCES suministro (cod_suministro);


-- 8. Evitar documentos de identidad duplicados.

ALTER TABLE personal
ADD CONSTRAINT uk_personal_documento
UNIQUE (documento_identidad);


-- 9. Validar las cantidades.

-- No se pueden solicitar cantidades iguales o menores que cero.
ALTER TABLE detalle_solicitud
ADD CONSTRAINT ck_cantidad_solicitada
CHECK (cantidad_solicitada > 0);

-- El stock puede ser cero, pero no negativo.
ALTER TABLE existencia
ADD CONSTRAINT ck_cantidad_disponible
CHECK (cantidad_disponible >= 0);

-- No se pueden registrar entregas de cero o cantidades negativas.
ALTER TABLE detalle_entrega
ADD CONSTRAINT ck_cantidad_entregada
CHECK (cantidad_entregada > 0);


-- 10. Validar el orden de las fechas.

-- La salida puede estar vacía si la membresía sigue vigente.
ALTER TABLE membresia
ADD CONSTRAINT ck_fechas_membresia
CHECK (
    fecha_salida IS NULL
    OR fecha_salida >= fecha_ingreso
);
