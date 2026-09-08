# Taller de ACID

**Estefania Paredes Castañeda**
Facultad de Ingeniería, Universidad El Bosque
Bases de Datos 2 — 25 de agosto de 2026

---

## Ejercicios de Verificación

### 1. Identificar el Problema

Código original (sin transacciones):

```sql
INSERT INTO pedidos (cliente_id, total, estado)
  VALUES (1, 500000, 'procesando');
UPDATE productos SET stock = stock - 3 WHERE producto_id = 2;
INSERT INTO pagos (pedido_id, monto, metodo, estado)
  VALUES (4, 500000, 'PSE', 'aprobado');
UPDATE pedidos SET estado = 'completado' WHERE pedido_id = 4;

-- ¿Qué pasa si el UPDATE de stock falla
-- pero el INSERT del pedido ya se ejecutó?
```

**Solución:**
Lo que pasa es que cada sentencia hace auto commit por separado, si la actualización UPDATE del stock llega a fallar, por ejemplo, que no haya suficiente inventario y no cumple la condición CHECK (stock >= 0), el INSERT del pedido ya quedó confirmado en la base de datos.

Como resultado se tiene un pedido procesando que realmente nunca se pagó o se descontó inventario. Es una inconsistencia en la base de datos.

**Script corregido:**

```sql
BEGIN;

INSERT INTO pedidos (cliente_id, total, estado) VALUES (1, 500000, 'procesando');

UPDATE productos SET stock = stock - 3 WHERE producto_id = 2;

INSERT INTO pagos (pedido_id, monto, metodo, estado)
VALUES (currval('pedidos_pedido_id_seq'), 500000, 'PSE', 'aprobado');

UPDATE pedidos SET estado = 'completado'
WHERE pedido_id = currval('pedidos_pedido_id_seq');

COMMIT;
```

---

### 2. Completar la Transacción

Enunciado con espacios en blanco (reembolso de $180.000 al saldo de María):

```sql
_______;  -- Iniciar transacción

  UPDATE clientes SET saldo_favor = saldo_favor + 180000
    WHERE cliente_id = 1;

  UPDATE pedidos SET estado = '_________'
    WHERE pedido_id = 1;

  UPDATE productos SET stock = stock + 1
    WHERE producto_id = 3;

  _______ despues_reembolso;  -- Punto de control

  INSERT INTO pagos (pedido_id, monto, metodo, estado)
    VALUES (1, -180000, 'saldo_favor', 'aprobado');

_______;  -- Confirmar todo
```

**Solución:**

```sql
BEGIN; -- Iniciar transacción

UPDATE clientes SET saldo_favor = saldo_favor + 180000 WHERE cliente_id = 1;

UPDATE pedidos SET estado = 'cancelado' WHERE pedido_id = 1;

UPDATE productos SET stock = stock + 1 WHERE producto_id = 3;

SAVEPOINT despues_reembolso; -- Punto de control

INSERT INTO pagos (pedido_id, monto, metodo, estado)
VALUES (1, -180000, 'saldo_favor', 'aprobado');

COMMIT; -- Confirmar todo
```

---

### 3. Análisis de Escenario

```sql
BEGIN;
  UPDATE clientes SET saldo_favor = saldo_favor - 100000
    WHERE cliente_id = 1;
  SAVEPOINT sp1;
  UPDATE clientes SET saldo_favor = saldo_favor + 100000
    WHERE cliente_id = 2;
  ROLLBACK TO sp1;
  UPDATE clientes SET saldo_favor = saldo_favor + 100000
    WHERE cliente_id = 3;
COMMIT;
```

**a) ¿Se descontó el saldo de María (cliente 1)? ¿Por qué?**
Sí, ya que el UPDATE ocurre antes del SAVEPOINT sp1, entonces el ROLLBACK TO sp1 no lo va a afectar y quedaría confirmado con el COMMIT final.

**b) ¿Se acreditó a Carlos (cliente 2)? ¿Por qué?**
No, ya que el UPDATE ocurre después del sp1, y el ROLLBACK TO sp1 deshace todo desde ese punto en adelante, aquí incluyendo el crédito a Carlos.

**c) ¿Se acreditó a Ana (cliente 3)? ¿Por qué?**
Sí, ya que ese UPDATE se ejecutaría después del ROLLBACK TO sp1, entonces no sería afectado por revertir y quedaría confirmado con el COMMIT.

**d) ¿Hay un problema de consistencia? Explíquelo.**
Sí, ya que se le descontaron $100.000 a María, pero ese dinero terminó realmente en la cuenta de Ana y no en la de Carlos, que era la intención. El SAVEPOINT funcionó como se esperaba, pero la lógica de negocio dejó una transferencia mal: el dinero salió de una cuenta y entró a la que no estaba planeada. Esto significa que el SAVEPOINT, a pesar de que protege la integridad, no reemplaza una lógica de negocio bien planteada.

---

### 4. Nivel de Aislamiento Correcto

| Escenario | Nivel | Justificación |
|---|---|---|
| Dashboard en tiempo real de ventas (solo lectura) | READ COMMITTED | Solo se lee, se prioriza velocidad; pequeñas inconsistencias momentáneas son aceptables. |
| Sistema de nómina para 500 empleados | REPEATABLE READ | Cada empleado debe calcularse con la misma versión de los datos (tabla de deducciones, etc.) durante todo el proceso. |
| Venta de boletas de concierto (últimas 10, miles de usuarios) | SERIALIZABLE | Un error de concurrencia significaría vender la misma boleta dos veces; no se acepta, mejor abortar y reintentar. |
| Consulta de catálogo en app móvil | READ COMMITTED | Solo lectura, sin decisiones de escritura basadas en lo leído; se prioriza velocidad. |
