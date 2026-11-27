-- 1. Listado de solicitudes con su emergencia.
SELECT
    sa.cod_solicitud,
    sa.fecha_hora_registro,
    e.tipo_desastre,
    e.ubicacion,
    sa.descripcion_necesidad,
    sa.prioridad,
    sa.estado_atencion
FROM solicitud_ayuda sa
JOIN emergencia e
    ON sa.cod_emergencia = e.cod_emergencia
ORDER BY sa.fecha_hora_registro DESC, sa.cod_solicitud;
