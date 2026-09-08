-- ============================================================
-- Autor: Estefania Paredes Castañeda
-- Fecha: 07-08-2026
-- Descripción: Actividad 1 BD2 "Tienda Online" QUERY SQL
-- ============================================================

-- ============================================================
-- EJERCICIO 2: CONSULTAS BÁSICAS
-- SECCIÓN 1: CONSULTAS SELECT CON WHERE
-- ============================================================


-- CONSULTA 1
-- Productos que tienen un precio entre $40 y $80

SELECT *
FROM productos
WHERE precio BETWEEN 40 AND 80;


-- CONSULTA 2
-- Clientes cuyo nombre comienza con la letra M

SELECT *
FROM clientes
WHERE nombre LIKE 'M%';


-- CONSULTA 3
-- Productos que tienen menos de 30 unidades en stock

SELECT *
FROM productos
WHERE stock < 30;


-- CONSULTA 4
-- Pedidos realizados en el mes de enero de 2025

SELECT *
FROM pedidos
WHERE fecha_pedido BETWEEN '2025-01-01' AND '2025-01-31';


-- CONSULTA 5
-- Productos cuyo nombre contiene Adidas o Nike

SELECT *
FROM productos
WHERE nombre_producto LIKE '%Adidas%'
   OR nombre_producto LIKE '%Nike%';


-- CONSULTA 6
-- Clientes que tienen un email del dominio @email.com

SELECT *
FROM clientes
WHERE email LIKE '%@email.com';


-- CONSULTA 7
-- Productos de la categoría Hogar que cuestan menos de $100

SELECT
    p.producto_id,
    p.nombre_producto,
    p.precio,
    p.stock,
    c.nombre_categoria
FROM productos p
INNER JOIN categorias c
    ON p.categoria_id = c.categoria_id
WHERE c.nombre_categoria = 'Hogar'
  AND p.precio < 100;



-- ============================================================
-- SECCIÓN 2: OPERADORES LÓGICOS AND, OR, NOT
-- ============================================================


-- CONSULTA 1
-- Productos que cuestan más de $50 Y tienen stock mayor a 25

SELECT *
FROM productos
WHERE precio > 50
  AND stock > 25;


-- CONSULTA 2
-- Clientes que viven en Bogotá O en Cali

SELECT *
FROM clientes
WHERE ciudad = 'Bogotá'
   OR ciudad = 'Cali';


-- CONSULTA 3
-- Productos que NO pertenecen a la categoría Electrónica

SELECT *
FROM productos
WHERE categoria_id <> 1;


-- CONSULTA 4
-- Pedidos con total mayor a $100
-- y realizados después del 16 de enero de 2025

SELECT *
FROM pedidos
WHERE total > 100
  AND fecha_pedido > '2025-01-16';


-- CONSULTA 5
-- Productos de categoría Ropa O Deportes
-- que cuesten menos de $40

SELECT *
FROM productos
WHERE (categoria_id = 2 OR categoria_id = 4)
  AND precio < 40;


-- CONSULTA 6
-- Clientes que viven en Bogotá
-- y cuyo apellido NO es Pérez

SELECT *
FROM clientes
WHERE ciudad = 'Bogotá'
  AND apellido <> 'Pérez';


-- CONSULTA 7
-- Productos que tienen un precio menor a $30
-- O mayor a $100

SELECT *
FROM productos
WHERE precio < 30
   OR precio > 100;


-- CONSULTA 8
-- Pedidos realizados entre el 15 y el 18 de enero de 2025
-- y con total mayor a $80

SELECT *
FROM pedidos
WHERE fecha_pedido BETWEEN '2025-01-15' AND '2025-01-18'
  AND total > 80;



-- ============================================================
-- EJERCICIO 3: CONSULTAS AVANZADAS
-- SECCIÓN 1: JOINS
-- ============================================================


-- CONSULTA 1
-- Productos que nunca han sido pedidos
-- mostrando producto, precio y categoría

SELECT
    p.nombre_producto,
    p.precio,
    c.nombre_categoria
FROM productos p
INNER JOIN categorias c
    ON p.categoria_id = c.categoria_id
LEFT JOIN detalle_pedidos dp
    ON p.producto_id = dp.producto_id
WHERE dp.producto_id IS NULL;


-- CONSULTA 2
-- Detalle completo de cada pedido

SELECT
    pe.pedido_id AS numero_pedido,
    pe.fecha_pedido,
    CONCAT(cl.nombre, ' ', cl.apellido) AS nombre_cliente,
    cl.ciudad,
    pr.nombre_producto,
    dp.cantidad,
    dp.precio_unitario,
    dp.cantidad * dp.precio_unitario AS subtotal
FROM pedidos pe
INNER JOIN clientes cl
    ON pe.cliente_id = cl.cliente_id
INNER JOIN detalle_pedidos dp
    ON pe.pedido_id = dp.pedido_id
INNER JOIN productos pr
    ON dp.producto_id = pr.producto_id
ORDER BY pe.pedido_id, dp.detalle_id;


-- CONSULTA 3
-- Clientes que han comprado productos
-- de al menos 2 categorías diferentes

SELECT
    CONCAT(cl.nombre, ' ', cl.apellido) AS nombre_cliente,
    COUNT(DISTINCT pr.categoria_id) AS categorias_diferentes,
    SUM(dp.cantidad * dp.precio_unitario) AS total_gastado
FROM clientes cl
INNER JOIN pedidos pe
    ON cl.cliente_id = pe.cliente_id
INNER JOIN detalle_pedidos dp
    ON pe.pedido_id = dp.pedido_id
INNER JOIN productos pr
    ON dp.producto_id = pr.producto_id
GROUP BY
    cl.cliente_id,
    cl.nombre,
    cl.apellido
HAVING COUNT(DISTINCT pr.categoria_id) >= 2
ORDER BY categorias_diferentes DESC;


-- CONSULTA 4
-- Producto más caro de cada categoría

SELECT
    c.nombre_categoria,
    p.nombre_producto,
    p.precio
FROM categorias c
INNER JOIN productos p
    ON c.categoria_id = p.categoria_id
WHERE p.precio = (
    SELECT MAX(p2.precio)
    FROM productos p2
    WHERE p2.categoria_id = p.categoria_id
)
ORDER BY c.categoria_id;


-- CONSULTA 5
-- Pedidos donde se hayan comprado
-- más de 2 productos diferentes

SELECT
    pe.pedido_id AS numero_pedido,
    CONCAT(cl.nombre, ' ', cl.apellido) AS nombre_cliente,
    pe.fecha_pedido,
    COUNT(DISTINCT dp.producto_id) AS productos_diferentes
FROM pedidos pe
INNER JOIN clientes cl
    ON pe.cliente_id = cl.cliente_id
INNER JOIN detalle_pedidos dp
    ON pe.pedido_id = dp.pedido_id
GROUP BY
    pe.pedido_id,
    cl.nombre,
    cl.apellido,
    pe.fecha_pedido
HAVING COUNT(DISTINCT dp.producto_id) > 2
ORDER BY pe.pedido_id;



-- ============================================================
-- SECCIÓN 2: AGREGACIÓN Y AGRUPACIÓN
-- ============================================================


-- CONSULTA 1
-- Ticket promedio por ciudad
-- solo ciudades con promedio mayor a $100

SELECT
    cl.ciudad,
    ROUND(AVG(pe.total), 2) AS ticket_promedio
FROM clientes cl
INNER JOIN pedidos pe
    ON cl.cliente_id = pe.cliente_id
GROUP BY cl.ciudad
HAVING AVG(pe.total) > 100
ORDER BY ticket_promedio DESC;


-- CONSULTA 2
-- Categorías con valor total de inventario
-- mayor a $2.000

SELECT
    c.nombre_categoria,
    ROUND(SUM(p.precio * p.stock), 2) AS valor_total_inventario
FROM categorias c
INNER JOIN productos p
    ON c.categoria_id = p.categoria_id
GROUP BY
    c.categoria_id,
    c.nombre_categoria
HAVING SUM(p.precio * p.stock) > 2000
ORDER BY valor_total_inventario DESC;


-- CONSULTA 3
-- Los 3 productos más vendidos
-- por cantidad total vendida

SELECT
    p.nombre_producto,
    SUM(dp.cantidad) AS cantidad_total_vendida,
    ROUND(
        SUM(dp.cantidad * dp.precio_unitario),
        2
    ) AS ingresos_totales
FROM productos p
INNER JOIN detalle_pedidos dp
    ON p.producto_id = dp.producto_id
GROUP BY
    p.producto_id,
    p.nombre_producto
ORDER BY cantidad_total_vendida DESC
LIMIT 3;


-- CONSULTA 4
-- Información de compras de cada cliente:
-- nombre completo
-- número total de pedidos
-- cantidad total de productos comprados
-- gasto promedio por pedido

SELECT
    CONCAT(cl.nombre, ' ', cl.apellido) AS nombre_cliente,
    COUNT(DISTINCT pe.pedido_id) AS total_pedidos,
    COALESCE(SUM(dp.cantidad), 0) AS productos_comprados,
    COALESCE(
        ROUND(AVG(pe.total), 2),
        0
    ) AS gasto_promedio_por_pedido
FROM clientes cl
LEFT JOIN pedidos pe
    ON cl.cliente_id = pe.cliente_id
LEFT JOIN detalle_pedidos dp
    ON pe.pedido_id = dp.pedido_id
GROUP BY
    cl.cliente_id,
    cl.nombre,
    cl.apellido
ORDER BY cl.cliente_id;


-- CONSULTA 5
-- Ventas agrupadas por mes
-- cantidad de pedidos
-- ingresos totales
-- pedido promedio

SELECT
    DATE_FORMAT(fecha_pedido, '%Y-%m') AS mes,
    COUNT(*) AS cantidad_pedidos,
    ROUND(SUM(total), 2) AS ingresos_totales,
    ROUND(AVG(total), 2) AS pedido_promedio
FROM pedidos
GROUP BY DATE_FORMAT(fecha_pedido, '%Y-%m')
ORDER BY mes;

-- URL de DB Fiddle: https://www.db-fiddle.com/f/tTHBcjBS39RBUBNDPr3LKy/2
