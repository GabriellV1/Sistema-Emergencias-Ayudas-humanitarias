-- SISTEMA DE EMERGENCIAS Y AYUDA HUMANITARIA
-- Actividad DML: INSERT y UPDATE en PostgreSQL.

BEGIN;

-- INSERT: CINCO REGISTROS EN CADA TABLA.

-- 1. EMERGENCIA

INSERT INTO emergencia (
    cod_emergencia, tipo_desastre, fecha_hora_ocurrencia,
    ubicacion, descripcion, estado_atencion
) VALUES
    ('EM001', 'Sismo', '2026-11-01 08:00:00',
     'Cayma, Arequipa', 'Escenario simulado de viviendas afectadas.', 'en atención'),
    ('EM002', 'Inundacion', '2026-11-01 09:00:00',
     'Cerro Colorado, Arequipa', 'Escenario simulado de calles inundadas.', 'en atención'),
    ('EM003', 'Deslizamiento', '2026-11-01 10:00:00',
     'Alto Selva Alegre, Arequipa', 'Escenario simulado de acceso bloqueado.', 'en atención'),
    ('EM004', 'Incendio', '2026-11-01 11:00:00',
     'Mariano Melgar, Arequipa', 'Escenario simulado de incendio urbano.', 'en atención'),
    ('EM005', 'Vientos fuertes', '2026-11-01 12:00:00',
     'Paucarpata, Arequipa', 'Escenario simulado de techos afectados.', 'en atención');

-- 2. BRIGADA

INSERT INTO brigada (
    cod_brigada, nombre, especialidad, estado_operativo
) VALUES
    ('BR001', 'Brigada Alfa', 'Busqueda y rescate', 'operativa'),
    ('BR002', 'Brigada Beta', 'Atencion sanitaria', 'operativa'),
    ('BR003', 'Brigada Gamma', 'Logistica humanitaria', 'operativa'),
    ('BR004', 'Brigada Delta', 'Control de incendios', 'operativa'),
    ('BR005', 'Brigada Epsilon', 'Evaluacion de danos', 'operativa');

-- 3. PERSONAL

INSERT INTO personal (
    cod_personal, nombre_completo, documento_identidad, telefono, especialidad
) VALUES
    ('PE001', 'Persona de prueba 01', 'DEMO0001', '900000001', 'Rescate'),
    ('PE002', 'Persona de prueba 02', 'DEMO0002', '900000002', 'Enfermeria'),
    ('PE003', 'Persona de prueba 03', 'DEMO0003', '900000003', 'Logistica'),
    ('PE004', 'Persona de prueba 04', 'DEMO0004', '900000004', 'Control de incendios'),
    ('PE005', 'Persona de prueba 05', 'DEMO0005', '900000005', 'Evaluacion de danos');

-- 4. SOLICITUD DE AYUDA

INSERT INTO solicitud_ayuda (
    cod_solicitud, cod_emergencia, fecha_hora_registro,
    descripcion_necesidad, prioridad, estado_atencion
) VALUES
    ('SOL001', 'EM001', '2026-11-01 08:30:00',
     'Agua potable y apoyo de rescate.', 'media', 'en atención'),
    ('SOL002', 'EM002', '2026-11-01 09:30:00',
     'Alimentos y apoyo sanitario.', 'alta', 'en atención'),
    ('SOL003', 'EM003', '2026-11-01 10:30:00',
     'Frazadas y apoyo logistico.', 'media', 'en atención'),
    ('SOL004', 'EM004', '2026-11-01 11:30:00',
     'Mascarillas y control de incendio.', 'alta', 'en atención'),
    ('SOL005', 'EM005', '2026-11-01 12:30:00',
     'Carpas y evaluacion de viviendas.', 'media', 'en atención');

-- 5. MEMBRESIA
-- NULL en fecha_salida significa que la pertenencia sigue vigente.
INSERT INTO membresia (
    cod_membresia, cod_personal, cod_brigada, fecha_ingreso, fecha_salida
) VALUES
    ('ME001', 'PE001', 'BR001', '2026-10-01', NULL),
    ('ME002', 'PE002', 'BR002', '2026-10-01', NULL),
    ('ME003', 'PE003', 'BR003', '2026-10-01', NULL),
    ('ME004', 'PE004', 'BR004', '2026-10-01', NULL),
    ('ME005', 'PE005', 'BR005', '2026-10-01', NULL);

-- 6. ASIGNACION
INSERT INTO asignacion (
    cod_asignacion, cod_solicitud, cod_brigada,
    fecha_hora_asignacion, estado_atencion, fecha_hora_finalizacion
) VALUES
    ('AS001', 'SOL001', 'BR001', '2026-11-01 08:45:00', 'asignada', NULL),
    ('AS002', 'SOL002', 'BR002', '2026-11-01 09:45:00', 'asignada', NULL),
    ('AS003', 'SOL003', 'BR003', '2026-11-01 10:45:00', 'asignada', NULL),
    ('AS004', 'SOL004', 'BR004', '2026-11-01 11:45:00', 'asignada', NULL),
    ('AS005', 'SOL005', 'BR005', '2026-11-01 12:45:00', 'asignada', NULL);
























-- PARTE B. DOCE UPDATE: UNO POR TABLA, TODOS CON WHERE.

-- 1. Ampliar la descripcion de una emergencia.
UPDATE emergencia
SET descripcion = 'Escenario simulado: diez viviendas requieren evaluacion.'
WHERE cod_emergencia = 'EM001';

-- 2. Precisar la especialidad de una brigada.
UPDATE brigada
SET especialidad = 'Busqueda, rescate y evacuacion'
WHERE cod_brigada = 'BR001';

-- 3. Corregir un telefono de prueba.
UPDATE personal
SET telefono = '900000101'
WHERE cod_personal = 'PE001';

-- 4. Dar mayor prioridad a una solicitud.
UPDATE solicitud_ayuda
SET prioridad = 'alta'
WHERE cod_solicitud = 'SOL001';

-- 5. Corregir la fecha de ingreso de una membresia de prueba.
UPDATE membresia
SET fecha_ingreso = '2026-09-15'
WHERE cod_membresia = 'ME005';





