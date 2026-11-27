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

-- 8. PERSONAL CON MEMBRESÍA VIGENTE
-- La membresía debe haber comenzado.
-- La fecha de salida se considera inclusiva.

SELECT
    m.cod_membresia,
    b.cod_brigada,
    b.nombre AS brigada,
    p.cod_personal,
    p.nombre_completo,
    p.telefono,
    p.especialidad AS especialidad_personal,
    m.fecha_ingreso,
    m.fecha_salida
FROM membresia m
JOIN brigada b
    ON m.cod_brigada = b.cod_brigada
JOIN personal p
    ON m.cod_personal = p.cod_personal
WHERE m.fecha_ingreso <= CURRENT_DATE
  AND (
      m.fecha_salida IS NULL
      OR m.fecha_salida >= CURRENT_DATE
  )
ORDER BY
    b.cod_brigada,
    p.nombre_completo,
    m.cod_membresia;


-- 9. HISTORIAL DETALLADO DE ENTREGAS

SELECT
    e.cod_entrega,
    e.fecha_hora,
    e.cod_solicitud,
    a.cod_almacen,
    a.nombre AS almacen,
    e.nombre_receptor,
    s.cod_suministro,
    s.nombre AS suministro,
    s.unidad_medida,
    de.cantidad_entregada
FROM entrega e
JOIN almacen a
    ON e.cod_almacen = a.cod_almacen
JOIN detalle_entrega de
    ON e.cod_entrega = de.cod_entrega
JOIN suministro s
    ON de.cod_suministro = s.cod_suministro
ORDER BY
    e.fecha_hora DESC,
    e.cod_entrega,
    s.cod_suministro;


-- 10. SOLICITUDES SIN ASIGNACIONES ABIERTAS
SELECT
    sa.cod_solicitud,
    sa.fecha_hora_registro,
    sa.prioridad,
    sa.estado_atencion,
    sa.descripcion_necesidad,
    e.tipo_desastre,
    e.ubicacion
FROM solicitud_ayuda sa
JOIN emergencia e
    ON sa.cod_emergencia = e.cod_emergencia
WHERE NOT EXISTS (
    SELECT 1
    FROM asignacion ag
    WHERE ag.cod_solicitud = sa.cod_solicitud
      AND ag.fecha_hora_finalizacion IS NULL
)
ORDER BY
    CASE sa.prioridad
        WHEN 'alta' THEN 1
        WHEN 'media' THEN 2
        WHEN 'baja' THEN 3
        ELSE 4
    END,
    sa.fecha_hora_registro,
    sa.cod_solicitud;


-- 11. RESUMEN DE SOLICITUDES POR EMERGENCIA

SELECT
    e.cod_emergencia,
    e.tipo_desastre,
    e.ubicacion,
    e.estado_atencion AS estado_emergencia,
    COUNT(sa.cod_solicitud) AS total_solicitudes,
    COUNT(sa.cod_solicitud) FILTER (
        WHERE sa.prioridad = 'alta'
    ) AS solicitudes_prioridad_alta,
    COUNT(sa.cod_solicitud) FILTER (
        WHERE sa.estado_atencion = 'pendiente'
    ) AS solicitudes_pendientes,
    COUNT(sa.cod_solicitud) FILTER (
        WHERE sa.estado_atencion = 'en atención'
    ) AS solicitudes_en_atencion
FROM emergencia e
LEFT JOIN solicitud_ayuda sa
    ON e.cod_emergencia = sa.cod_emergencia
GROUP BY
    e.cod_emergencia,
    e.tipo_desastre,
    e.ubicacion,
    e.estado_atencion
ORDER BY
    total_solicitudes DESC,
    e.cod_emergencia;


-- 12. DEMANDA PENDIENTE FRENTE AL STOCK TOTAL
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
),
demanda AS (
    SELECT
        ds.cod_suministro,
        SUM(
            GREATEST(
                ds.cantidad_solicitada
                    - COALESCE(en.total_entregado, 0),
                0
            )
        ) AS total_pendiente
    FROM detalle_solicitud ds
    LEFT JOIN entregado en
        ON ds.cod_solicitud = en.cod_solicitud
       AND ds.cod_suministro = en.cod_suministro
    GROUP BY ds.cod_suministro
),
stock AS (
    SELECT
        cod_suministro,
        SUM(cantidad_disponible) AS total_disponible
    FROM existencia
    GROUP BY cod_suministro
)
SELECT
    s.cod_suministro,
    s.nombre AS suministro,
    s.unidad_medida,
    COALESCE(d.total_pendiente, 0) AS demanda_pendiente,
    COALESCE(st.total_disponible, 0) AS stock_disponible,
    GREATEST(
        COALESCE(d.total_pendiente, 0)
            - COALESCE(st.total_disponible, 0),
        0
    ) AS cantidad_faltante
FROM suministro s
LEFT JOIN demanda d
    ON s.cod_suministro = d.cod_suministro
LEFT JOIN stock st
    ON s.cod_suministro = st.cod_suministro
ORDER BY
    cantidad_faltante DESC,
    s.cod_suministro;


-- 13. BRIGADAS OPERATIVAS SIN ASIGNACIONES ABIERTAS

SELECT
    b.cod_brigada,
    b.nombre AS brigada,
    b.especialidad,
    b.estado_operativo
FROM brigada b
WHERE b.estado_operativo = 'operativa'
  AND NOT EXISTS (
      SELECT 1
      FROM asignacion ag
      WHERE ag.cod_brigada = b.cod_brigada
        AND ag.fecha_hora_finalizacion IS NULL
  )
ORDER BY b.cod_brigada;


-- 14. SOLICITUDES SIN DETALLE DE SUMINISTROS
-- Permite revisar solicitudes que no tienen suministros.
-- No implica necesariamente un error: una solicitud
-- podría requerir únicamente intervención de una brigada.

SELECT
    sa.cod_solicitud,
    sa.fecha_hora_registro,
    sa.descripcion_necesidad,
    sa.prioridad,
    sa.estado_atencion
FROM solicitud_ayuda sa
WHERE NOT EXISTS (
    SELECT 1
    FROM detalle_solicitud ds
    WHERE ds.cod_solicitud = sa.cod_solicitud
)
ORDER BY
    sa.fecha_hora_registro,
    sa.cod_solicitud;


-- 15. CONTROL DE ENTREGAS INCONSISTENTES


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
    en.cod_solicitud,
    s.cod_suministro,
    s.nombre AS suministro,
    s.unidad_medida,
    ds.cantidad_solicitada,
    en.total_entregado,
    CASE
        WHEN ds.cod_solicitud IS NULL
            THEN 'Suministro no solicitado'
        ELSE 'Cantidad entregada superior a la solicitada'
    END AS observacion
FROM entregado en
JOIN suministro s
    ON en.cod_suministro = s.cod_suministro
LEFT JOIN detalle_solicitud ds
    ON en.cod_solicitud = ds.cod_solicitud
   AND en.cod_suministro = ds.cod_suministro
WHERE ds.cod_solicitud IS NULL
   OR en.total_entregado > ds.cantidad_solicitada
ORDER BY
    en.cod_solicitud,
    s.cod_suministro;


-- 16. ENTREGAS SIN DETALLE

SELECT
    e.cod_entrega,
    e.cod_solicitud,
    e.cod_almacen,
    e.fecha_hora,
    e.nombre_receptor
FROM entrega e
WHERE NOT EXISTS (
    SELECT 1
    FROM detalle_entrega de
    WHERE de.cod_entrega = e.cod_entrega
)
ORDER BY
    e.fecha_hora,
    e.cod_entrega;
