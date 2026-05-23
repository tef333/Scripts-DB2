# Oracle SQL & PL/SQL Scripts 📚

**Autores:** Estefania Paredes Castañeda · Santiago Rojas Galeano  
**Curso:** Bases de Datos 2  
**Base de datos:** Oracle (esquema HR + esquemas propios)

---

## Estructura del repositorio

```
oracle-sql-scripts/
│
├── 01_consultas_sql/          # Consultas SQL (JOINs, funciones, jerarquías)
├── 02_plsql_anonimos/         # Bloques anónimos PL/SQL (variables, ciclos, cursores)
├── 03_procedimientos/         # Stored procedures y permisos
├── 04_triggers_excepciones/   # Triggers DML y manejo de excepciones
└── 05_taller_final/           # Taller T1: ajuste salarial con ACID
```

---

## Descripción por carpeta

### 01 — Consultas SQL
Consultas sobre el esquema `HR` de Oracle. Incluye LEFT JOINs, funciones de cadena (`LPAD`, `SUBSTR`), `GROUP BY`, `HAVING`, y jerarquías con self-join.

### 02 — Bloques PL/SQL anónimos
Bloques `DECLARE / BEGIN / END` con variables, condicionales `IF`, ciclos `WHILE` y `LOOP`, y un cursor explícito.

### 03 — Procedimientos almacenados
Stored procedures con parámetros `IN`, convenciones de nomenclatura de variables, y gestión de permisos con `GRANT`.

### 04 — Triggers y excepciones
Estructura de triggers `BEFORE/AFTER` para eventos DML, y bloques con manejo de excepciones (`WHEN OTHERS`, excepciones declaradas por el usuario).

### 05 — Taller final
Script completo del taller de ajuste salarial: diagnóstico con CTEs, decisión de elegibles, prevalidación, actualización con SAVEPOINT, auditoría e INSERT en tabla de log, y validación posterior. Aplica propiedades ACID.
