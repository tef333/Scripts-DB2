# Detective SQL — Solución

**Estefania Paredes Castañeda**
Bases de Datos 2

---

## Caso 1

```sql
SELECT product_name, price
FROM products
WHERE status = 'ACTIVE'
  AND price > (
    SELECT AVG(price)
    FROM products
    WHERE status = 'ACTIVE'
  )
ORDER BY price DESC;
```

**Justificación:**
El promedio de precio de los productos activos indicó 788.97. Con ese valor, 5 productos quedaron por encima (el más barato de la lista fue Laptop Business 14 con 932.90). Si ese producto bajara justo hasta 788.97, dejaría de aparecer en el resultado, porque la condición usa `>` estricto y no `>=`, entonces un precio exactamente igual al promedio no cumple la condición.

---

## Caso 2

```sql
SELECT c.customer_name
FROM customers c
WHERE c.customer_segment = 'VIP'
  AND EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.total_amount > 30000
  );

-- Segunda parte de la pregunta: complemento exacto con NOT EXISTS
SELECT c.customer_name
FROM customers c
WHERE c.customer_segment = 'VIP'
  AND NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.total_amount > 30000
  );
```

**Justificación:**
La consulta con `EXISTS` devolvió 4 filas: TechStore Retail, Empresa ABC Corp, Premium Electronics y SmartBuy Inc. Al reemplazar por `NOT EXISTS` con la condición negada, me dio 0 filas. Esto confirma que sí es el complemento exacto: como en mi base los 4 clientes VIP tienen al menos un pedido grande, no queda ninguno en el "resto", y entre las dos consultas se cubren exactamente los 4 VIP sin que sobre ni falte nadie.

---

## Caso 3

```sql
SELECT
    e.employee_name,
    e.salary,
    (SELECT ROUND(AVG(e2.salary), 2)
     FROM employees e2
     WHERE e2.department_id = e.department_id) AS promedio_departamento,
    e.salary - (SELECT ROUND(AVG(e2.salary), 2)
                FROM employees e2
                WHERE e2.department_id = e.department_id) AS diferencia
FROM employees e
WHERE e.department_id = 1
ORDER BY e.salary DESC;

-- 3b. Window function (una sola pasada, más eficiente)
SELECT
    employee_name,
    salary,
    ROUND(AVG(salary) OVER (PARTITION BY department_id), 2) AS promedio_departamento,
    salary - ROUND(AVG(salary) OVER (PARTITION BY department_id), 2) AS diferencia
FROM employees
WHERE department_id = 1
ORDER BY salary DESC;
```

**Justificación:**
Los dos enfoques (subconsulta correlacionada y window function) indican resultados idénticos fila por fila, mismo orden y mismos valores, porque ambos calculan el promedio sobre el mismo conjunto de datos. En mi resultado, Pedro Sánchez quedó como el sospechoso: su salario es 424,184.89 contra un promedio de departamento de 138,241.23, es decir, más del doble (2x el promedio serían 276,482.46). La diferencia exacta fue de 285,943.66 pesos por encima del promedio.

---

## Caso 4

```sql
WITH ventas_empleado AS (
    SELECT
        e.employee_name,
        SUM(o.total_amount) AS total_vendido
    FROM orders o
    JOIN employees e ON e.employee_id = o.employee_id
    WHERE e.department_id = 1
    GROUP BY e.employee_name
)
SELECT
    employee_name,
    total_vendido,
    ROUND(100 * total_vendido / SUM(total_vendido) OVER (), 2) AS porcentaje_del_total
FROM ventas_empleado
ORDER BY total_vendido DESC;
```

**Justificación:**
El vendedor top en el resultado fue Javier López con 30.94% del total. Si él dejara de vender, el total general bajaría de 1,752,268.86 a 1,210,177.17 (se le resta su total vendido). El segundo lugar, Diego Morales, pasaría de 23.37% a aproximadamente 33.84%, porque su mismo monto ahora se calcula sobre una base más pequeña.

---

## Caso 5

```sql
WITH RECURSIVE organigrama AS (
    -- Caso base
    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS nivel,
        CAST(NULL AS VARCHAR(100)) AS jefe_directo
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Caso recursivo
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        o.nivel + 1,
        o.employee_name AS jefe_directo
    FROM employees e
    JOIN organigrama o ON e.manager_id = o.employee_id
)
SELECT employee_name, nivel, jefe_directo
FROM organigrama
ORDER BY nivel, employee_name;
```

**Justificación:**
La organización tiene 3 niveles de profundidad (0, 1 y 2). En el nivel más profundo (nivel 2) quedaron Carmen Vega, Diego Morales, Javier López y Pedro Sánchez (reportando a Rosa Jiménez), y Luis Ramírez y Sofía Castro (reportando a Ana Silva). La cadena completa para, por ejemplo, Pedro Sánchez es: Gerente General → Rosa Jiménez → Pedro Sánchez.

---

## Caso 6

```sql
WITH ventas_empleado AS (
    SELECT
        e.employee_name,
        SUM(o.total_amount) AS total_vendido
    FROM orders o
    JOIN employees e ON e.employee_id = o.employee_id
    WHERE e.department_id = 1
    GROUP BY e.employee_name
)
SELECT
    employee_name,
    total_vendido,
    ROW_NUMBER() OVER (ORDER BY total_vendido DESC) AS ranking,
    SUM(total_vendido) OVER (
        ORDER BY total_vendido DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS acumulado,
    total_vendido - LAG(total_vendido) OVER (ORDER BY total_vendido DESC) AS diferencia_vs_anterior
FROM ventas_empleado
ORDER BY total_vendido DESC;
```

**Justificación:**
La brecha entre el primer y segundo lugar (Javier López vs Diego Morales) fue de 132,556.41 pesos. Entre el último lugar y el que le sigue (Carmen Vega vs Pedro Sánchez) la brecha fue mucho menor, de solo 11,921.47 pesos. Esto me dice que las ventas no están parejas: hay un vendedor claramente destacado (Javier López) muy por encima del resto, mientras que los últimos tres están bastante concentrados entre sí.
