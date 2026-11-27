-- 1. LISTADO DE EMERGENCIAS
-- Muestra primero las emergencias más recientes.

SELECT
    cod_emergencia,
    tipo_desastre,
    fecha_hora_ocurrencia,
    ubicacion,
    descripcion,
    estado_atencion
FROM emergencia
ORDER BY
    fecha_hora_ocurrencia DESC,
    cod_emergencia;


-- 2. SOLICITUDES CON SU EMERGENCIA
-- Permite identificar el origen y la prioridad de cada solicitud.

SELECT
    sa.cod_solicitud,
    sa.fecha_hora_registro,
    e.cod_emergencia,
    e.tipo_desastre,
    e.ubicacion,
    sa.descripcion_necesidad,
    sa.prioridad,
    sa.estado_atencion
FROM solicitud_ayuda sa
JOIN emergencia e
    ON sa.cod_emergencia = e.cod_emergencia
ORDER BY
    sa.fecha_hora_registro DESC,
    sa.cod_solicitud;

-- 3. DETALLE DE LOS SUMINISTROS SOLICITADOS
-- Una solicitud puede aparecer varias veces:
-- una fila por cada suministro solicitado.

SELECT
    sa.cod_solicitud,
    sa.prioridad,
    sa.estado_atencion,
    s.cod_suministro,
    s.nombre AS suministro,
    s.unidad_medida,
    ds.cantidad_solicitada
FROM solicitud_ayuda sa
JOIN detalle_solicitud ds
    ON sa.cod_solicitud = ds.cod_solicitud
JOIN suministro s
    ON ds.cod_suministro = s.cod_suministro
ORDER BY
    sa.cod_solicitud,
    s.cod_suministro;

