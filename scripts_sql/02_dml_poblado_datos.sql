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
