# Sesión: JOIN y Subconsultas
### Bases de Datos 2 — Universidad El Bosque

Setup del esquema y datos de práctica: ver `00_setup.sql` en esta misma carpeta.

---

## Bloque 1 — JOIN

### Los 4 tipos de JOIN

| Tipo | Qué conserva | Caso típico |
|---|---|---|
| INNER JOIN | Solo filas con coincidencia en ambas tablas | Reportes de ventas reales |
| LEFT JOIN | Todas las de la izquierda, con o sin pareja | Encontrar registros huérfanos |
| RIGHT JOIN | Todas las de la derecha, con o sin pareja | Poco usado, se prefiere LEFT invertido |
| FULL OUTER JOIN | Todas las filas de ambas tablas | Auditorías / conciliaciones |

---

### INNER JOIN

```sql
SELECT p.nombre, pe.fecha, dp.cantidad
FROM detalle_pedidos dp
JOIN productos p ON dp.producto_id = p.id
JOIN pedidos pe ON dp.pedido_id = pe.id;
```

**Ejercicio 1** — Nombre de cada producto junto con su categoría:
```sql
SELECT p.nombre AS producto, c.nombre AS categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id;
```

**Ejercicio 2** — Pedidos con el nombre del cliente, ordenados por fecha descendente:
```sql
SELECT pe.id, pe.fecha, CONCAT(cl.nombre,' ',cl.apellido) AS cliente
FROM pedidos pe
JOIN clientes cl ON pe.cliente_id = cl.id
ORDER BY pe.fecha DESC;
```

**Ejercicio 3 (encadenado, 3 tablas)** — Cliente, producto, cantidad y subtotal por línea de pedido:
```sql
SELECT CONCAT(cl.nombre,' ',cl.apellido) AS cliente,
       pr.nombre AS producto, dp.cantidad,
       (dp.cantidad * dp.precio_unitario) AS subtotal
FROM detalle_pedidos dp
JOIN pedidos pe ON dp.pedido_id = pe.id
JOIN clientes cl ON pe.cliente_id = cl.id
JOIN productos pr ON dp.producto_id = pr.id;
```

---

### LEFT JOIN

```sql
SELECT cl.nombre, cl.apellido, pe.id AS pedido_id
FROM clientes cl
LEFT JOIN pedidos pe ON cl.id = pe.cliente_id
WHERE pe.id IS NULL;
```
> Patrón "anti-join": LEFT JOIN + WHERE ... IS NULL para encontrar registros huérfanos.

**Ejercicio 1** — Categorías con la cantidad de productos (incluyendo las de 0):
```sql
SELECT c.nombre AS categoria, COUNT(p.id) AS numero_productos
FROM categorias c
LEFT JOIN productos p ON p.categoria_id = c.id
GROUP BY c.id, c.nombre;
```

**Ejercicio 2 (anti-join)** — Productos que nunca han sido pedidos:
```sql
SELECT p.nombre, p.precio
FROM productos p
LEFT JOIN detalle_pedidos dp ON dp.producto_id = p.id
WHERE dp.id IS NULL;
```

**Ejercicio 3** — Total gastado por cliente, mostrando 0 en vez de NULL:
```sql
SELECT CONCAT(cl.nombre,' ',cl.apellido) AS cliente,
       COALESCE(SUM(pe.total), 0) AS total_gastado
FROM clientes cl
LEFT JOIN pedidos pe ON pe.cliente_id = cl.id
GROUP BY cl.id, cl.nombre, cl.apellido;
```

---

### RIGHT JOIN y FULL OUTER JOIN

```sql
SELECT c.nombre, p.nombre
FROM productos p
RIGHT JOIN categorias c ON p.categoria_id = c.id;
```

**Ejercicio (FULL OUTER JOIN)** — Clientes sin pedidos y pedidos sin cliente válido, en una sola consulta:
```sql
SELECT cl.nombre, pe.id AS pedido_id
FROM clientes cl
FULL OUTER JOIN pedidos pe ON cl.id = pe.cliente_id
WHERE cl.id IS NULL OR pe.id IS NULL;
```

---

### Self-Join

```sql
SELECT p1.nombre, p2.nombre, p1.categoria_id
FROM productos p1
JOIN productos p2 ON p1.categoria_id = p2.categoria_id
AND p1.id < p2.id;
```
> La condición `p1.id < p2.id` evita parejas repetidas y que un producto se empareje consigo mismo.

**Ejercicio 1** — Pares de productos de la misma categoría con diferencia de precio > $100.000:
```sql
SELECT p1.nombre AS producto_1, p2.nombre AS producto_2,
       ABS(p1.precio - p2.precio) AS diferencia
FROM productos p1
JOIN productos p2 ON p1.categoria_id = p2.categoria_id AND p1.id < p2.id
WHERE ABS(p1.precio - p2.precio) > 100000;
```

**Ejercicio 2** — Parejas de clientes que viven en la misma ciudad:
```sql
SELECT c1.nombre AS cliente_1, c2.nombre AS cliente_2, c1.ciudad
FROM clientes c1
JOIN clientes c2 ON c1.ciudad = c2.ciudad AND c1.id < c2.id;
```

---

## Bloque 2 — Subconsultas

Clasificación:

| Clasificación | Devuelve | Ejemplo |
|---|---|---|
| Escalar | Un solo valor | El precio promedio de todos los productos |
| De fila / lista | Varios valores en una columna | IDs de categorías con más de 3 productos |
| De tabla | Filas y columnas (se usa en FROM) | Ventas agregadas por categoría |

---

### Subconsulta escalar en WHERE

```sql
SELECT nombre, precio FROM productos
WHERE precio > (
  SELECT AVG(precio) FROM productos
);
```
> No correlacionada: no depende de la consulta externa, se ejecuta una sola vez.

**Ejercicio 1** — Pedidos con total mayor al promedio general:
```sql
SELECT id, fecha, total
FROM pedidos
WHERE total > (SELECT AVG(total) FROM pedidos);
```

**Ejercicio 2** — Producto(s) con el precio más alto, sin ORDER BY ni LIMIT:
```sql
SELECT nombre, precio
FROM productos
WHERE precio = (SELECT MAX(precio) FROM productos);
```

**Ejercicio 3** — Productos de "Deportes" con stock por debajo del promedio de su categoría:
```sql
SELECT nombre, stock
FROM productos
WHERE categoria_id = 4
  AND stock < (SELECT AVG(stock) FROM productos WHERE categoria_id = 4);
```

---

### IN / NOT IN

```sql
SELECT nombre FROM clientes
WHERE id NOT IN (
  SELECT cliente_id FROM pedidos
);
```
> ⚠️ Cuidado con `NOT IN` cuando la subconsulta puede devolver `NULL`: un solo `NULL` en la lista hace que `NOT IN` devuelva la tabla vacía sin avisar. `NOT EXISTS` no tiene ese problema.

**Ejercicio 1** — Productos de categorías con más de 3 productos registrados:
```sql
SELECT nombre, categoria_id
FROM productos
WHERE categoria_id IN (
  SELECT categoria_id FROM productos
  GROUP BY categoria_id
  HAVING COUNT(*) > 3
);
```

**Ejercicio 2** — Clientes que nunca han hecho un pedido (con NOT IN):
```sql
SELECT nombre, apellido
FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos);
```

**Ejercicio 3** — Productos que sí han sido pedidos al menos una vez:
```sql
SELECT nombre FROM productos
WHERE id IN (SELECT DISTINCT producto_id FROM detalle_pedidos);
```

---

### EXISTS / NOT EXISTS

```sql
SELECT cl.nombre FROM clientes cl
WHERE EXISTS (
  SELECT 1 FROM pedidos pe
  WHERE pe.cliente_id = cl.id
);
```
> Casi siempre correlacionada: se re-ejecuta por cada fila de la consulta externa. En bases grandes suele ser más eficiente que IN porque puede parar en la primera coincidencia.

**Ejercicio 1** — Clientes que han comprado algo de "Deportes" (categoria_id = 4):
```sql
SELECT cl.nombre FROM clientes cl
WHERE EXISTS (
  SELECT 1 FROM pedidos pe
  JOIN detalle_pedidos dp ON dp.pedido_id = pe.id
  JOIN productos pr ON dp.producto_id = pr.id
  WHERE pe.cliente_id = cl.id AND pr.categoria_id = 4
);
```

**Ejercicio 2** — Clientes que NUNCA han comprado nada de "Electrónica" (con NOT EXISTS):
```sql
SELECT cl.nombre FROM clientes cl
WHERE NOT EXISTS (
  SELECT 1 FROM pedidos pe
  JOIN detalle_pedidos dp ON dp.pedido_id = pe.id
  JOIN productos pr ON dp.producto_id = pr.id
  WHERE pe.cliente_id = cl.id AND pr.categoria_id = 1
);
```

**Ejercicio 3** — Categorías con al menos un producto (con EXISTS en vez de LEFT JOIN):
```sql
SELECT nombre FROM categorias c
WHERE EXISTS (SELECT 1 FROM productos p WHERE p.categoria_id = c.id);
```

---

### Subconsulta correlacionada

```sql
SELECT p.nombre, p.precio, p.categoria_id
FROM productos p
WHERE p.precio = (
  SELECT MAX(p2.precio) FROM productos p2
  WHERE p2.categoria_id = p.categoria_id
);
```
> Devuelve el producto más caro **de cada categoría**, comparando cada fila contra el máximo de su propio grupo.

**Ejercicio** — Pedidos que superan el promedio de gasto **de ese mismo cliente** (no el promedio general):
```sql
SELECT pe.id, pe.cliente_id, pe.total
FROM pedidos pe
WHERE pe.total > (
  SELECT AVG(pe2.total) FROM pedidos pe2
  WHERE pe2.cliente_id = pe.cliente_id
);
```

---

### Subconsulta en FROM

```sql
SELECT c.nombre, avg_precio.promedio
FROM (
  SELECT categoria_id, AVG(precio) AS promedio
  FROM productos GROUP BY categoria_id
) AS avg_precio
JOIN categorias c ON c.id = avg_precio.categoria_id;
```
> El alias (`AS avg_precio`) es obligatorio: sin él, SQL da error.

**Ejercicio** — Categoría con el precio promedio de productos más alto:
```sql
SELECT c.nombre, avg_precio.promedio
FROM (
  SELECT categoria_id, AVG(precio) AS promedio
  FROM productos GROUP BY categoria_id
) AS avg_precio
JOIN categorias c ON c.id = avg_precio.categoria_id
ORDER BY avg_precio.promedio DESC
LIMIT 1;
```

---

## Checkpoint — JOIN vs. Subconsulta

| Necesito... | Uso... |
|---|---|
| Comparar contra un valor único calculado | Subconsulta escalar |
| Comparar contra una lista de valores | IN / NOT IN |
| Solo verificar si existe al menos una coincidencia | EXISTS / NOT EXISTS |
| Encontrar huérfanos (con NULLs seguros) | LEFT JOIN + IS NULL, o NOT EXISTS |
| Comparar cada fila contra "lo suyo" (su categoría, su cliente) | Subconsulta correlacionada |
| Reutilizar un cálculo agrupado como si fuera una tabla | Subconsulta en FROM |

> 📌 Regla práctica: si la pregunta es "tráeme columnas combinadas de dos tablas", casi siempre es JOIN. Si la pregunta es "filtra según un cálculo", casi siempre es subconsulta. Muchas veces ambos caminos llegan al mismo resultado — la elección depende de legibilidad y rendimiento, no de que uno sea "más avanzado" que el otro.
