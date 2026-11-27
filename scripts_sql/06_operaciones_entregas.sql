-- Buscar entregas por solicitud.
CREATE INDEX idx_entrega_solicitud
ON entrega (cod_solicitud);

-- Resumen de entregas.
CREATE OR REPLACE VIEW vista_resumen_entregas AS
SELECT
    e.cod_entrega,
    e.fecha_hora,
    e.cod_solicitud,
    sa.cod_emergencia,
    a.cod_almacen,
    a.nombre AS almacen,
    e.nombre_receptor,
    COUNT(de.cod_suministro) AS tipos_suministro
FROM entrega e
JOIN solicitud_ayuda sa
    ON e.cod_solicitud = sa.cod_solicitud
JOIN almacen a
    ON e.cod_almacen = a.cod_almacen
LEFT JOIN detalle_entrega de
    ON e.cod_entrega = de.cod_entrega
GROUP BY
    e.cod_entrega,
    e.fecha_hora,
    e.cod_solicitud,
    sa.cod_emergencia,
    a.cod_almacen,
    a.nombre,
    e.nombre_receptor;
