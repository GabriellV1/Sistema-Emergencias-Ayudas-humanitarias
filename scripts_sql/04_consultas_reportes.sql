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


-- 4. CANTIDADES SOLICITADAS, ENTREGADAS Y PENDIENTES
-- Suma las entregas por solicitud y suministro.
-- Incluye suministros que todavía no tienen entregas.
-- Un pendiente negativo indica una entrega excesiva.

WITH entregado AS (
    SELECT
        e.cod_solicitud,
        de.cod_suministro,
        SUM(de.cantidad_entregada) AS total_entregado
    FROM entrega e
    JOIN detalle_entrega de
        ON e.cod_entrega = de.cod_entrega
    GROUP BY
        e.cod_solicitud,
        de.cod_suministro
)
SELECT
    ds.cod_solicitud,
    s.cod_suministro,
    s.nombre AS suministro,
    s.unidad_medida,
    ds.cantidad_solicitada,
    COALESCE(en.total_entregado, 0) AS cantidad_entregada,
    ds.cantidad_solicitada
        - COALESCE(en.total_entregado, 0)
        AS cantidad_pendiente
FROM detalle_solicitud ds
JOIN suministro s
    ON ds.cod_suministro = s.cod_suministro
LEFT JOIN entregado en
    ON ds.cod_solicitud = en.cod_solicitud
   AND ds.cod_suministro = en.cod_suministro
ORDER BY
    ds.cod_solicitud,
    s.cod_suministro;


-- 5. STOCK REGISTRADO POR ALMACÉN
-- Incluye existencias con saldo cero.
-- Una combinación almacén-suministro sin registro no aparece.

SELECT
    a.cod_almacen,
    a.nombre AS almacen,
    a.direccion,
    s.cod_suministro,
    s.nombre AS suministro,
    s.unidad_medida,
    ex.cantidad_disponible
FROM existencia ex
JOIN almacen a
    ON ex.cod_almacen = a.cod_almacen
JOIN suministro s
    ON ex.cod_suministro = s.cod_suministro
ORDER BY
    a.cod_almacen,
    s.cod_suministro;

-- 6. STOCK TOTAL POR SUMINISTRO
-- Suma el mismo suministro entre todos los almacenes.
-- Si no tiene existencias registradas, muestra cero.
-- No mezcla suministros ni unidades de medida diferentes.

SELECT
    s.cod_suministro,
    s.nombre AS suministro,
    s.unidad_medida,
    COALESCE(SUM(ex.cantidad_disponible), 0)
        AS stock_total_registrado
FROM suministro s
LEFT JOIN existencia ex
    ON s.cod_suministro = ex.cod_suministro
GROUP BY
    s.cod_suministro,
    s.nombre,
    s.unidad_medida
ORDER BY
    s.nombre,
    s.cod_suministro;


-- 7. ASIGNACIONES DE BRIGADAS
-- Incluye el historial completo de asignaciones.
-- Una finalización NULL identifica una asignación abierta.

SELECT
    ag.cod_asignacion,
    sa.cod_solicitud,
    e.cod_emergencia,
    e.tipo_desastre,
    e.ubicacion,
    b.cod_brigada,
    b.nombre AS brigada,
    b.especialidad,
    ag.fecha_hora_asignacion,
    ag.estado_atencion AS estado_asignacion,
    ag.fecha_hora_finalizacion
FROM asignacion ag
JOIN solicitud_ayuda sa
    ON ag.cod_solicitud = sa.cod_solicitud
JOIN emergencia e
    ON sa.cod_emergencia = e.cod_emergencia
JOIN brigada b
    ON ag.cod_brigada = b.cod_brigada
ORDER BY
    ag.fecha_hora_asignacion DESC,
    ag.cod_asignacion;

