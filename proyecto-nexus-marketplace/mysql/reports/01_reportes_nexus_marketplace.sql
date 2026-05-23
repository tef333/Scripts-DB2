-- ============================================================
-- NEXUS MARKETPLACE - REPORTES SQL
-- Base de Datos II | Universidad El Bosque
-- Motor: MySQL 8.x | Base de datos: marketplace
--
-- Modelo:
-- usuario, cliente, administrador, categoria, producto,
-- inventario, carrito, item_carrito, pedido, detalle_pedido,
-- pago, envio
-- ============================================================

USE marketplace;

-- ============================================================
-- REPORTE 1: VENTAS TOTALES POR CLIENTE
-- ============================================================
SELECT
    cl.cedula                                          AS documento,
    CONCAT(cl.nombre, ' ', cl.apellido)                AS cliente,
    u.correo_electronico                               AS correo,
    COUNT(DISTINCT ped.id_pedido)                      AS total_compras,
    SUM(dp.cantidad * dp.precio_unitario)              AS subtotal,
    SUM(pa.monto)                                      AS total_pagado
FROM cliente               cl
JOIN usuario               u    ON u.correo_electronico = cl.correo_electronico
JOIN pedido                ped  ON ped.cedula_cliente   = cl.cedula
JOIN detalle_pedido        dp   ON dp.id_pedido         = ped.id_pedido
JOIN pago                  pa   ON pa.id_pedido         = ped.id_pedido
WHERE ped.estado_pedido != 'cancelado'
GROUP BY
    cl.cedula, cl.nombre, cl.apellido, u.correo_electronico
ORDER BY
    total_pagado DESC;

-- ============================================================
-- REPORTE 2: PRODUCTOS MAS VENDIDOS
-- ============================================================
SELECT
    pr.codigo                                          AS codigo_producto,
    pr.nombre                                          AS producto,
    cat.nombre_categoria                               AS categoria,
    SUM(dp.cantidad)                                   AS unidades_vendidas,
    pr.precio                                          AS precio_unitario,
    SUM(dp.cantidad * dp.precio_unitario)              AS ingresos_totales
FROM producto              pr
JOIN categoria             cat  ON cat.id_categoria    = pr.id_categoria
JOIN detalle_pedido        dp   ON dp.codigo_producto  = pr.codigo
JOIN pedido                ped  ON ped.id_pedido       = dp.id_pedido
WHERE ped.estado_pedido != 'cancelado'
GROUP BY
    pr.codigo, pr.nombre, cat.nombre_categoria, pr.precio
ORDER BY
    unidades_vendidas DESC;

-- ============================================================
-- REPORTE 3: ESTADO ACTUAL DEL INVENTARIO
-- ============================================================
SELECT
    pr.codigo                                          AS codigo,
    pr.nombre                                          AS producto,
    cat.nombre_categoria                               AS categoria,
    pr.precio                                          AS precio_cop,
    inv.cantidad                                       AS stock_disponible,
    CASE
        WHEN inv.cantidad = 0   THEN 'SIN STOCK'
        WHEN inv.cantidad < 10  THEN 'STOCK BAJO'
        WHEN inv.cantidad < 20  THEN 'STOCK MEDIO'
        ELSE                         'STOCK OK'
    END                                                AS estado_inventario
FROM producto              pr
JOIN categoria             cat  ON cat.id_categoria      = pr.id_categoria
LEFT JOIN inventario       inv  ON inv.codigo_producto   = pr.codigo
ORDER BY
    inv.cantidad ASC,
    cat.nombre_categoria,
    pr.nombre;

-- ============================================================
-- REPORTE 4: INGRESOS MENSUALES
-- ============================================================
SELECT
    YEAR(ped.fecha_pedido)                             AS anio,
    MONTH(ped.fecha_pedido)                            AS mes,
    DATE_FORMAT(ped.fecha_pedido, '%M %Y')             AS periodo,
    COUNT(DISTINCT ped.id_pedido)                      AS total_pedidos,
    SUM(dp.cantidad)                                   AS unidades_vendidas,
    SUM(dp.cantidad * dp.precio_unitario)              AS ingresos_totales
FROM pedido                ped
JOIN detalle_pedido        dp   ON dp.id_pedido = ped.id_pedido
WHERE ped.estado_pedido != 'cancelado'
GROUP BY
    YEAR(ped.fecha_pedido),
    MONTH(ped.fecha_pedido),
    DATE_FORMAT(ped.fecha_pedido, '%M %Y')
ORDER BY
    anio DESC, mes DESC;

-- ============================================================
-- REPORTE 5: VENTAS POR METODO DE PAGO
-- ============================================================
SELECT
    pa.metodo_pago                                     AS metodo_pago,
    COUNT(DISTINCT pa.id_pedido)                       AS total_transacciones,
    SUM(dp.cantidad)                                   AS unidades_vendidas,
    SUM(dp.cantidad * dp.precio_unitario)              AS ingresos_totales,
    ROUND(
        COUNT(DISTINCT pa.id_pedido) * 100.0
        / SUM(COUNT(DISTINCT pa.id_pedido)) OVER (), 2
    )                                                  AS porcentaje_uso
FROM pago                  pa
JOIN pedido                ped  ON ped.id_pedido  = pa.id_pedido
JOIN detalle_pedido        dp   ON dp.id_pedido   = ped.id_pedido
WHERE ped.estado_pedido != 'cancelado'
GROUP BY
    pa.metodo_pago
ORDER BY
    total_transacciones DESC;

-- ============================================================
-- REPORTE 6: VENTAS POR CATEGORIA DE PRODUCTO
-- ============================================================
SELECT
    cat.nombre_categoria                               AS categoria,
    cat.descripcion                                    AS descripcion_categoria,
    COUNT(DISTINCT pr.codigo)                          AS productos_activos,
    SUM(dp.cantidad)                                   AS unidades_vendidas,
    SUM(dp.cantidad * dp.precio_unitario)              AS ingresos_totales,
    ROUND(
        SUM(dp.cantidad * dp.precio_unitario) * 100.0
        / SUM(SUM(dp.cantidad * dp.precio_unitario)) OVER (), 2
    )                                                  AS participacion_pct
FROM categoria             cat
JOIN producto              pr   ON pr.id_categoria    = cat.id_categoria
JOIN detalle_pedido        dp   ON dp.codigo_producto = pr.codigo
JOIN pedido                ped  ON ped.id_pedido      = dp.id_pedido
WHERE ped.estado_pedido != 'cancelado'
GROUP BY
    cat.id_categoria, cat.nombre_categoria, cat.descripcion
ORDER BY
    ingresos_totales DESC;

-- ============================================================
-- REPORTE 7: DISTRIBUCION GEOGRAFICA DE CLIENTES Y VENTAS
-- ============================================================
SELECT
    cl.ciudad                                          AS ciudad,
    COUNT(DISTINCT cl.cedula)                          AS total_clientes,
    COUNT(DISTINCT ped.id_pedido)                      AS total_pedidos,
    COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0) AS valor_total_ventas
FROM cliente               cl
LEFT JOIN pedido           ped  ON ped.cedula_cliente  = cl.cedula
                               AND ped.estado_pedido  != 'cancelado'
LEFT JOIN detalle_pedido   dp   ON dp.id_pedido        = ped.id_pedido
GROUP BY
    cl.ciudad
HAVING
    total_clientes > 0
ORDER BY
    valor_total_ventas DESC,
    total_clientes DESC;

-- ============================================================
-- REPORTE 8: RESUMEN EJECUTIVO - INDICADORES GENERALES
-- ============================================================
SELECT
    (SELECT COUNT(*) FROM usuario
     WHERE rol = 'cliente')                            AS total_clientes,

    (SELECT COUNT(*) FROM usuario
     WHERE rol = 'administrador')                      AS total_administradores,

    (SELECT COUNT(*) FROM producto)                    AS total_productos_catalogo,

    (SELECT COUNT(*) FROM categoria)                   AS total_categorias,

    (SELECT SUM(cantidad) FROM inventario)             AS unidades_totales_stock,

    (SELECT COUNT(*) FROM inventario
     WHERE cantidad = 0)                               AS productos_sin_stock,

    (SELECT COUNT(*) FROM pedido
     WHERE estado_pedido != 'cancelado')               AS total_pedidos_activos,

    (SELECT SUM(monto) FROM pago)                      AS ingresos_totales_cop,

    (SELECT AVG(monto) FROM pago)                      AS ticket_promedio_cop;

