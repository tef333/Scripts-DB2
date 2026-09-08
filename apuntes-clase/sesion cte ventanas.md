# Sesión: CTE y Funciones de Ventana
### Bases de Datos 2 — Universidad El Bosque

Continúa sobre la misma base de datos de la sesión de JOIN y Subconsultas. Setup adicional (tabla `empleados`): ver `00_setup.sql` en esta misma carpeta.

---

## Bloque 1 — CTE (Common Table Expressions)

### Qué es un CTE

Un CTE es un resultado con nombre, definido antes de la consulta principal con `WITH`, que existe solo durante esa ejecución. Resuelve el mismo problema que una subconsulta en `FROM`, pero queda declarado arriba con un nombre legible en vez de anidado entre paréntesis.

**Comparación directa:**
```sql
-- Subconsulta en FROM (visto en la sesión de JOIN y Subconsultas)
SELECT c.nombre, avg_precio.promedio
FROM (
  SELECT categoria_id, AVG(precio) AS promedio
  FROM productos GROUP BY categoria_id
) AS avg_precio
JOIN categorias c ON c.id = avg_precio.categoria_id;

-- Lo mismo, con CTE
WITH promedio_por_categoria AS (
  SELECT categoria_id, AVG(precio) AS promedio
  FROM productos GROUP BY categoria_id
)
SELECT c.nombre, ppc.promedio
FROM promedio_por_categoria ppc
JOIN categorias c ON c.id = ppc.categoria_id;
```

---

### CTE básico

**Ejercicio 1** — Total gastado por cliente, mostrando solo quienes gastaron más de $300.000:
```sql
WITH gasto_cliente AS (
  SELECT cl.id, CONCAT(cl.nombre,' ',cl.apellido) AS cliente, SUM(pe.total) AS total_gastado
  FROM clientes cl
  JOIN pedidos pe ON pe.cliente_id = cl.id
  GROUP BY cl.id, cl.nombre, cl.apellido
)
SELECT cliente, total_gastado
FROM gasto_cliente
WHERE total_gastado > 300000;
```

**Ejercicio 2** — Categorías con menos de 3 productos (con LEFT JOIN adentro, para no perder categorías vacías):
```sql
WITH productos_por_categoria AS (
  SELECT c.id, c.nombre, COUNT(p.id) AS total_productos
  FROM categorias c
  LEFT JOIN productos p ON p.categoria_id = c.id
  GROUP BY c.id, c.nombre
)
SELECT nombre, total_productos
FROM productos_por_categoria
WHERE total_productos < 3;
```

**Ejercicio 3** — Ticket promedio por ciudad, ordenado de mayor a menor:
```sql
WITH ticket_por_ciudad AS (
  SELECT cl.ciudad, AVG(pe.total) AS ticket_promedio
  FROM clientes cl
  JOIN pedidos pe ON pe.cliente_id = cl.id
  GROUP BY cl.ciudad
)
SELECT ciudad, ticket_promedio
FROM ticket_por_ciudad
ORDER BY ticket_promedio DESC;
```

---

### CTEs múltiples encadenados

Se pueden declarar varios CTE separados por coma, y un CTE posterior puede usar a uno anterior (nunca al revés).

```sql
WITH ingresos_por_categoria AS (
  SELECT c.id, c.nombre, SUM(dp.cantidad * dp.precio_unitario) AS ingresos
  FROM categorias c
  JOIN productos p ON p.categoria_id = c.id
  JOIN detalle_pedidos dp ON dp.producto_id = p.id
  GROUP BY c.id, c.nombre
),
total_general AS (
  -- este segundo CTE usa el primero
  SELECT SUM(ingresos) AS total FROM ingresos_por_categoria
)
SELECT ipc.nombre, ipc.ingresos,
       ROUND(100.0 * ipc.ingresos / tg.total, 2) AS porcentaje
FROM ingresos_por_categoria ipc, total_general tg
ORDER BY porcentaje DESC;
```

**Ejercicio 1** — Productos que vendieron más unidades que el promedio de unidades vendidas:
```sql
WITH ventas_por_producto AS (
  SELECT pr.id, pr.nombre, SUM(dp.cantidad) AS unidades_vendidas
  FROM productos pr
  JOIN detalle_pedidos dp ON dp.producto_id = pr.id
  GROUP BY pr.id, pr.nombre
),
promedio_ventas AS (
  SELECT AVG(unidades_vendidas) AS promedio FROM ventas_por_producto
)
SELECT vp.nombre, vp.unidades_vendidas
FROM ventas_por_producto vp, promedio_ventas pv
WHERE vp.unidades_vendidas > pv.promedio;
```

**Ejercicio 2** — Clasificar clientes como 'Top' o 'Regular' según si superan el promedio general de gasto:
```sql
WITH gasto_cliente AS (
  SELECT cl.id, CONCAT(cl.nombre,' ',cl.apellido) AS cliente,
         COALESCE(SUM(pe.total), 0) AS total_gastado
  FROM clientes cl
  LEFT JOIN pedidos pe ON pe.cliente_id = cl.id
  GROUP BY cl.id, cl.nombre, cl.apellido
),
promedio_gasto AS (
  SELECT AVG(total_gastado) AS promedio FROM gasto_cliente
)
SELECT gc.cliente, gc.total_gastado,
       CASE WHEN gc.total_gastado > pg.promedio THEN 'Top' ELSE 'Regular' END AS clasificacion
FROM gasto_cliente gc, promedio_gasto pg
ORDER BY gc.total_gastado DESC;
```

---

### CTE recursivo

Se usa cuando una tabla tiene una relación jerárquica consigo misma (como `empleados.jefe_id`, que apunta a otro empleado). Tiene 3 partes obligatorias:

| Parte | Qué hace |
|---|---|
| Miembro ancla | El punto de partida — normalmente un WHERE que fija la raíz |
| UNION ALL | Conecta el ancla con la parte recursiva |
| Miembro recursivo | Se vuelve a ejecutar usando su propio resultado anterior, hasta que ya no encuentra más filas |

```sql
WITH RECURSIVE subordinados AS (
  -- Miembro ancla: arrancamos en Andrés Silva (id = 2)
  SELECT id, nombre, jefe_id, 1 AS nivel
  FROM empleados
  WHERE id = 2

  UNION ALL

  -- Miembro recursivo: empleados cuyo jefe YA está en el resultado
  SELECT e.id, e.nombre, e.jefe_id, s.nivel + 1
  FROM empleados e
  JOIN subordinados s ON e.jefe_id = s.id
)
SELECT * FROM subordinados;
```

**Ejercicio 1** — Todos los que reportan (directa o indirectamente) a Patricia Gómez (id = 1), sin incluirla:
```sql
WITH RECURSIVE subordinados AS (
  SELECT id, nombre, jefe_id, 1 AS nivel
  FROM empleados
  WHERE id = 1

  UNION ALL

  SELECT e.id, e.nombre, e.jefe_id, s.nivel + 1
  FROM empleados e
  JOIN subordinados s ON e.jefe_id = s.id
)
SELECT nombre, nivel FROM subordinados WHERE id <> 1;
```

**Ejercicio 2** — Nivel máximo de profundidad de toda la empresa (ancla en la raíz, jefe_id IS NULL):
```sql
WITH RECURSIVE jerarquia AS (
  SELECT id, nombre, jefe_id, 1 AS nivel
  FROM empleados
  WHERE jefe_id IS NULL

  UNION ALL

  SELECT e.id, e.nombre, e.jefe_id, j.nivel + 1
  FROM empleados e
  JOIN jerarquia j ON e.jefe_id = j.id
)
SELECT MAX(nivel) AS profundidad_maxima FROM jerarquia;
```

---

## Bloque 2 — Funciones de Ventana

### La diferencia con GROUP BY

GROUP BY colapsa varias filas en una sola por grupo. Una función de ventana calcula algo **por grupo**, pero sin perder ninguna fila.

```sql
funcion() OVER (
  PARTITION BY columna   -- define los grupos, sin colapsar filas
  ORDER BY columna       -- define el orden dentro de cada grupo
)
```

Tres familias: **ranking** (ROW_NUMBER, RANK, DENSE_RANK), **agregación en ventana** (SUM, AVG sin colapsar) y **desplazamiento** (LAG, LEAD).

---

### ROW_NUMBER

```sql
SELECT nombre, categoria_id, precio,
       ROW_NUMBER() OVER (
         PARTITION BY categoria_id
         ORDER BY precio DESC
       ) AS posicion
FROM productos;
```
> La numeración se reinicia en 1 cada vez que cambia `categoria_id` — eso hace `PARTITION BY`.

**Ejercicio 1** — Numerar los pedidos de cada cliente por fecha, del más antiguo al más reciente:
```sql
SELECT cl.nombre, pe.fecha, pe.total,
       ROW_NUMBER() OVER (PARTITION BY pe.cliente_id ORDER BY pe.fecha ASC) AS numero_pedido
FROM pedidos pe
JOIN clientes cl ON pe.cliente_id = cl.id
ORDER BY cl.nombre, numero_pedido;
```

**Ejercicio 2** — Pedido más reciente de cada cliente, sin usar MAX ni GROUP BY:
```sql
WITH pedidos_numerados AS (
  SELECT cl.nombre, pe.fecha, pe.total,
         ROW_NUMBER() OVER (PARTITION BY pe.cliente_id ORDER BY pe.fecha DESC) AS rn
  FROM pedidos pe
  JOIN clientes cl ON pe.cliente_id = cl.id
)
SELECT nombre, fecha, total FROM pedidos_numerados WHERE rn = 1;
```
> Este patrón (CTE + ROW_NUMBER + filtrar rn = 1) reemplaza la subconsulta correlacionada con MAX que se usaba antes para lo mismo.

---

### RANK y DENSE_RANK

Igual que ROW_NUMBER, pero si dos filas empatan en el valor de ORDER BY, reciben el mismo número. La diferencia está en qué pasa después del empate.

```sql
SELECT nombre, precio,
       ROW_NUMBER() OVER (ORDER BY precio DESC) AS rn,
       RANK() OVER (ORDER BY precio DESC) AS rk,
       DENSE_RANK() OVER (ORDER BY precio DESC) AS drk
FROM productos
ORDER BY precio DESC;
```
> Con un empate en $45.000, RANK salta el siguiente número (deja hueco), DENSE_RANK no deja huecos.

**Ejercicio 1** — RANK de productos por precio, dentro de cada categoría:
```sql
SELECT nombre, categoria_id, precio,
       RANK() OVER (PARTITION BY categoria_id ORDER BY precio DESC) AS posicion
FROM productos
ORDER BY categoria_id, posicion;
```

**Ejercicio 2** — Producto más caro de cada categoría, usando CTE + RANK, filtrando posición = 1:
```sql
WITH ranking_productos AS (
  SELECT nombre, categoria_id, precio,
         RANK() OVER (PARTITION BY categoria_id ORDER BY precio DESC) AS posicion
  FROM productos
)
SELECT nombre, categoria_id, precio
FROM ranking_productos
WHERE posicion = 1;
```

---

### Agregación en ventana

Las funciones de agregación que ya se conocen (SUM, AVG, COUNT, MAX, MIN) también funcionan con `OVER` — y ahí dejan de colapsar el resultado en una sola fila por grupo.

```sql
-- Total acumulado de gasto por cliente, pedido a pedido (running total)
SELECT cl.nombre, pe.fecha, pe.total,
       SUM(pe.total) OVER (
         PARTITION BY pe.cliente_id
         ORDER BY pe.fecha
       ) AS acumulado
FROM pedidos pe
JOIN clientes cl ON pe.cliente_id = cl.id
ORDER BY cl.nombre, pe.fecha;
```

**Ejercicio 1** — Precio promedio de la categoría de cada producto, sin agrupar:
```sql
SELECT nombre, categoria_id, precio,
       AVG(precio) OVER (PARTITION BY categoria_id) AS promedio_categoria
FROM productos
ORDER BY categoria_id;
```

**Ejercicio 2** — Porcentaje que representa cada línea de un pedido sobre el total de ese pedido:
```sql
SELECT pedido_id, producto_id,
       (cantidad * precio_unitario) AS subtotal,
       ROUND(
         100.0 * (cantidad * precio_unitario) /
         SUM(cantidad * precio_unitario) OVER (PARTITION BY pedido_id),
       2) AS porcentaje_del_pedido
FROM detalle_pedidos
ORDER BY pedido_id;
```

---

### LAG y LEAD

`LAG` trae el valor de la fila anterior dentro de la partición; `LEAD` trae el de la fila siguiente.

```sql
SELECT cl.nombre, pe.fecha, pe.total,
       LAG(pe.total) OVER (
         PARTITION BY pe.cliente_id
         ORDER BY pe.fecha
       ) AS pedido_anterior
FROM pedidos pe
JOIN clientes cl ON pe.cliente_id = cl.id
ORDER BY cl.nombre, pe.fecha;
```
> El primer pedido de cada cliente no tiene "anterior" — LAG devuelve NULL ahí (comportamiento correcto, no es un error).

**Ejercicio 1** — Diferencia entre el total de un pedido y el del pedido anterior del mismo cliente:
```sql
SELECT cl.nombre, pe.fecha, pe.total,
       pe.total - LAG(pe.total) OVER (PARTITION BY pe.cliente_id ORDER BY pe.fecha) AS diferencia
FROM pedidos pe
JOIN clientes cl ON pe.cliente_id = cl.id
ORDER BY cl.nombre, pe.fecha;
```

**Ejercicio 2** — Fecha del siguiente pedido del mismo cliente (NULL si es el último):
```sql
SELECT cl.nombre, pe.fecha,
       LEAD(pe.fecha) OVER (PARTITION BY pe.cliente_id ORDER BY pe.fecha) AS siguiente_pedido
FROM pedidos pe
JOIN clientes cl ON pe.cliente_id = cl.id
ORDER BY cl.nombre, pe.fecha;
```

---

### Top-N por grupo (patrón profesional)

Combinar CTE + ROW_NUMBER es la forma estándar de responder "los N mejores de cada grupo".

```sql
WITH ranking AS (
  SELECT nombre, categoria_id, precio,
         ROW_NUMBER() OVER (
           PARTITION BY categoria_id
           ORDER BY precio DESC
         ) AS posicion
  FROM productos
)
SELECT nombre, categoria_id, precio
FROM ranking
WHERE posicion <= 2
ORDER BY categoria_id, posicion;
```

**Ejercicio** — Los 2 clientes que más han gastado en total, dentro de cada ciudad:
```sql
WITH gasto_cliente AS (
  SELECT cl.id, CONCAT(cl.nombre,' ',cl.apellido) AS cliente, cl.ciudad,
         SUM(pe.total) AS total_gastado
  FROM clientes cl
  JOIN pedidos pe ON pe.cliente_id = cl.id
  GROUP BY cl.id, cl.nombre, cl.apellido, cl.ciudad
),
ranking AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY ciudad ORDER BY total_gastado DESC) AS posicion
  FROM gasto_cliente
)
SELECT cliente, ciudad, total_gastado
FROM ranking
WHERE posicion <= 2
ORDER BY ciudad, posicion;
```

---

## Checkpoint — Resumen Funciones de Ventana

| Necesito... | Uso... |
|---|---|
| Numerar filas dentro de un grupo, sin repetir | ROW_NUMBER() |
| Rankear con empates, dejando huecos después | RANK() |
| Rankear con empates, sin dejar huecos | DENSE_RANK() |
| Un total o promedio "en vivo", sin perder el detalle de cada fila | SUM() / AVG() OVER (...) |
| Comparar con la fila anterior o siguiente del mismo grupo | LAG() / LEAD() |
| Los N mejores de cada grupo | CTE + ROW_NUMBER + WHERE posicion <= N |
