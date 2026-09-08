# Motores de Bases de Datos — Notas de Clase
### Bases de Datos 2 — Universidad El Bosque
Profesor: Francisco Barguil

---

## 1. ¿Qué es un Motor de Base de Datos?

Un sistema de información siempre necesita procesar datos y guardarlos de forma confiable. El motor es el componente que une esas dos responsabilidades.

**Las tres capas de cualquier sistema de BD:**

| Capa | Función |
|---|---|
| Aplicación | Hace peticiones, nunca toca los datos directamente |
| Motor de BD | Interpreta consultas, optimiza ejecución, gestiona transacciones, controla concurrencia, garantiza integridad |
| Almacenamiento | Disco, SSD, RAM, nube — solo guarda bits, no sabe qué significan |

**Funciones principales del motor:**
- **Gestión de almacenamiento** — decide dónde van los datos en disco, usa B-Trees e índices para encontrarlos rápido.
- **Gestión de transacciones** — agrupa operaciones en unidades atómicas (se hacen todas o ninguna).
- **Control de concurrencia** — maneja múltiples usuarios simultáneos usando bloqueos y versiones.
- **Seguridad y permisos** — define quién puede leer, escribir o modificar cada tabla, fila o columna.

**Los 4 tipos de motores:**

| Tipo | Ejemplos | Características |
|---|---|---|
| Relacional (RDBMS) | MySQL, PostgreSQL, SQL Server, Oracle | Tablas estructuradas, SQL estándar, el más maduro |
| NoSQL | MongoDB, Redis, Cassandra, Neo4j | Flexible, sin esquema fijo, escala masiva |
| Distribuidas | Cassandra, Cloud Spanner, CockroachDB | Datos en múltiples servidores, alta disponibilidad |
| En Memoria | Redis, SAP HANA, VoltDB | Guardan en RAM, latencia de microsegundos |

---

## 2. Evolución de los Motores de BD

| Época | Hito |
|---|---|
| 1960s | Modelo Jerárquico (IMS de IBM) — datos organizados como árboles, muy rígido |
| 1969 | Modelo de Red (CODASYL) — un hijo puede tener múltiples padres, pero navegación manual |
| 1970 | Modelo Relacional — Edgar F. Codd publica su paper. Tablas simples + álgebra relacional, sin necesidad de conocer el almacenamiento físico |
| 1979–1990s | RDBMS domina — Oracle, IBM DB2, SQL Server, MySQL. SQL se normaliza como estándar |
| 2004–2010 | Nace NoSQL — Google (Bigtable) y Amazon (Dynamo) publican sus papers; nace MongoDB, Cassandra, Redis |
| 2012–hoy | NewSQL y Cloud — Google Spanner, CockroachDB intentan combinar ACID + escalabilidad horizontal; migración a servicios gestionados en la nube |

> 📌 El paper de Codd de 1970 le valió el Premio Turing en 1981 — el equivalente al Nobel en informática.

---

## 3. Bases de Datos Relacionales (RDBMS)

El estándar dorado para sistemas donde la integridad de los datos es crítica: bancos, ERP, salud, nómina.

**Claves — el corazón de las relaciones:**
- **Clave primaria**: identificador único e irrepetible de cada fila (ej: `id` en Clientes).
- **Clave foránea**: columna que apunta a la clave primaria de otra tabla (ej: `id_cliente` en Pedidos). El motor garantiza que no se pueda insertar un pedido con un `id_cliente` que no exista (integridad referencial).

```sql
-- Consulta con JOIN: traer pedidos con nombre del cliente
SELECT c.nombre, p.total, p.estado
FROM Pedidos p
INNER JOIN Clientes c ON p.id_cliente = c.id
WHERE p.estado = 'Pendiente'
ORDER BY p.total DESC;
```

**Ventajas:** integridad referencial garantizada, SQL maduro y universal, transacciones ACID completas, herramientas maduras (40+ años), ideal para datos estructurados, fácil de auditar.

**Desventajas:** escalabilidad principalmente vertical, esquema rígido (migraciones costosas), difícil con datos no estructurados, JOINs complejos pueden ser lentos, no diseñado para Big Data.

**PostgreSQL vs MySQL:**

| Característica | PostgreSQL | MySQL |
|---|---|---|
| Licencia | Open Source (PostgreSQL License) | Open Source (GPL) / Comercial |
| Cumplimiento SQL | Muy alto | Moderado |
| Tipos de datos | JSON, Arrays, Geoespacial, UUID | Básicos + JSON (versiones recientes) |
| Mejor para | Datos complejos, alta integridad | Aplicaciones web, lectura intensiva |
| Usado por | Instagram, Spotify, Skype | WordPress, Twitter (antes), Facebook (antes) |

---

## 4. Bases de Datos NoSQL

Surgió porque los RDBMS no podían escalar horizontalmente para los volúmenes de datos de internet.

> 📌 NoSQL no significa "sin SQL". Significa "Not Only SQL" — se puede usar SQL u otros lenguajes de consulta, pero no se depende exclusivamente de él.

**Los 4 modelos de datos NoSQL:**

| Modelo | Ejemplos | Ideal para |
|---|---|---|
| Documentos | MongoDB, CouchDB, Firestore | Apps web/móviles con datos cambiantes (JSON, sin esquema fijo) |
| Clave-Valor | Redis, DynamoDB, Riak | Caché, sesiones, contadores — el más simple y rápido |
| Grafos | Neo4j, Amazon Neptune, ArangoDB | Redes sociales, recomendaciones, detección de fraude |
| Columnas anchas | Apache Cassandra, HBase, Bigtable | IoT, métricas, logs, datos temporales |

**Ventajas:** escalabilidad horizontal nativa, esquema flexible, alto rendimiento en escritura masiva, diseñado para Big Data, distintos modelos para distintos problemas.

**Desventajas:** consistencia eventual (no inmediata), sin lenguaje de consulta estándar, menos maduro que RDBMS, transacciones limitadas, puede haber duplicación de datos.

---

## 5. Bases de Datos Distribuidas

Reparten los datos entre múltiples nodos (servidores), posiblemente en distintas ubicaciones, para eliminar el punto único de fallo y escalar más allá de un solo servidor.

**Dos técnicas fundamentales:**

1. **Replicación** — múltiples copias iguales de los datos. Un nodo primario (líder) recibe las escrituras y las replica a nodos secundarios. Si el primario cae, una réplica toma el control (failover).

2. **Sharding** — los datos se particionan (ej: una tabla de 100M de filas dividida en 4 shards por rango de usuarios). Cada shard vive en un servidor distinto, repartiendo la carga horizontalmente.

> 📌 **Teorema CAP** (Eric Brewer): en un sistema distribuido solo se pueden garantizar 2 de estas 3 propiedades:
> - **Consistency** — todos ven los mismos datos
> - **Availability** — el sistema siempre responde
> - **Partition Tolerance** — funciona aunque falle la red
>
> Cassandra elige AP. Google Spanner elige CP.

---

## 6. Bases de Datos en Memoria (In-Memory)

Almacenan los datos principalmente en RAM en vez de disco. El acceso a RAM es entre 100 y 100.000 veces más rápido que un SSD, llevando la latencia a microsegundos.

| | RAM | SSD (Disco) |
|---|---|---|
| Velocidad | ~100 nanosegundos | ~100.000 nanosegundos |
| Persistencia | Volátil (se pierde al apagar) | Persistente |
| Costo por GB | Costosa | Económica |
| Capacidad | Limitada | Casi ilimitada |

**Estrategias de persistencia en Redis:**

| Modo | Cómo funciona | Riesgo de pérdida |
|---|---|---|
| RDB (Snapshot) | Copia completa a disco cada N minutos | Últimos N minutos |
| AOF (Append-Only) | Registra cada operación en un log en disco | Hasta 1 segundo |
| RDB + AOF | Combinación de ambos | Mínimo |
| Sin persistencia | Solo RAM, máxima velocidad | Todo al reiniciar |

> 📌 Twitter usa Redis para timelines, GitHub para caché, Uber para gestión de sesiones — cuando la velocidad importa más que la durabilidad, in-memory es la respuesta.

---

## 7. Principios ACID

Garantías que todo RDBMS maduro debe cumplir para que las transacciones sean confiables.

| Principio | Qué garantiza |
|---|---|
| **A**tomicidad | Una transacción es indivisible: todos sus pasos se ejecutan, o ninguno. Si un paso falla, los anteriores se revierten (ROLLBACK) |
| **C**onsistencia | La BD siempre pasa de un estado válido a otro estado válido — se cumplen todas las reglas, constraints y validaciones |
| **I**solamiento (Isolation) | Las transacciones concurrentes no se ven entre sí hasta completarse — cada una ejecuta como si fuera la única |
| **D**urabilidad | Una vez hecho COMMIT, los cambios son permanentes, incluso ante un fallo del sistema (gracias al WAL — Write-Ahead Log) |

**Ejemplo de Atomicidad:**
```sql
BEGIN TRANSACTION;
  UPDATE cuentas SET saldo = saldo - 100000 WHERE id = 1; -- Ana
  UPDATE cuentas SET saldo = saldo + 100000 WHERE id = 2; -- Luis
COMMIT; -- solo aquí los cambios son reales
```

**Ejemplo de Consistencia:**
```sql
CONSTRAINT saldo_positivo CHECK (saldo >= 0)
-- El motor rechaza cualquier transacción que deje saldo < 0, aunque sea por un instante.
```

**Ejemplo de Aislamiento:**
```
T1: lee saldo Ana = $500k
T2: lee saldo Ana = $500k  ← ve el mismo valor
T1: resta $300k → commit
T2: resta $300k → ERROR (saldo insuficiente) ← el motor detecta el conflicto
```

**Caso de estudio — Transferencia bancaria de $100k (Ana → Luis):**

1. `BEGIN TRANSACTION` — se abre un espacio de trabajo aislado, invisible para otros hasta el COMMIT.
2. Debitar $100k de Ana ($500k → $400k) — se verifica el constraint `saldo >= 0`. Válido.
3. Acreditar $100k a Luis ($200k → $300k) — el total del sistema sigue en $700k. Consistencia mantenida.
4. **Escenario de falla**: si la luz se va entre el paso 2 y el 3, al reiniciar el motor detecta la transacción incompleta y hace ROLLBACK automático. El saldo de Ana vuelve a $500k — Atomicidad en acción.
5. `COMMIT` — el motor escribe en el WAL (disco), los cambios se vuelven visibles y permanentes — Durabilidad garantizada.

---

## 8. ACID vs BASE en NoSQL

Las bases NoSQL adoptan el modelo **BASE**, que sacrifica consistencia inmediata a cambio de mayor disponibilidad y escalabilidad. No es un error, es una decisión de diseño para casos de uso específicos.

**Qué significa BASE:**
- **BA — Basically Available**: el sistema siempre responde, aunque los datos no sean los más recientes.
- **S — Soft State**: el estado puede cambiar con el tiempo sin input externo, mientras los nodos se sincronizan.
- **E — Eventually Consistent**: con el tiempo todos los nodos llegan al mismo estado, aunque no de inmediato.

**Comparativa ACID vs BASE:**

| Característica | ACID | BASE |
|---|---|---|
| Prioridad principal | Consistencia e integridad | Disponibilidad y escalabilidad |
| Consistencia | Inmediata, garantizada | Eventual (milisegundos a segundos) |
| Escalabilidad | Vertical | Horizontal |
| Disponibilidad | Puede sacrificarse por consistencia | Máxima prioridad |
| Complejidad | Modelo conocido y maduro | Requiere diseño cuidadoso |
| Tolerancia a fallos | Depende de réplicas configuradas | Diseñado para fallos esperados |
| Caso de uso ideal | Banca, salud, ERP, contabilidad | Redes sociales, IoT, streaming, caché |
| Ejemplos | PostgreSQL, MySQL, Oracle | Cassandra, MongoDB, DynamoDB |

**Usar ACID cuando:** los datos son dinero, salud o legal; una inconsistencia significa pérdidas reales; se necesita auditoría y trazabilidad; hay transacciones complejas multi-tabla; el volumen es manejable (<100M filas).

**Usar BASE cuando:** se escala a millones de usuarios; una inconsistencia de 1 segundo no importa; se prioriza velocidad de respuesta; los datos no son estructurados o son semiestructurados; hay alta escritura concurrente.

> 📌 La mayoría de sistemas modernos usan **ambos modelos**. Ejemplo: un e-commerce puede usar PostgreSQL (ACID) para pedidos y pagos, y Redis (BASE) para el carrito de compras y el catálogo. No es una guerra — es elegir la herramienta correcta para cada problema.
