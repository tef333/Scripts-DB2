# Diseno documental MongoDB - Nexus Marketplace

## Contexto

Nexus Marketplace requiere una base de datos no relacional con MongoDB para almacenar informacion flexible o semiestructurada. Esta informacion no encaja bien en tablas rigidas porque puede variar por tipo de producto y crecer dinamicamente.

La base propuesta almacena:

- Resenas y valoraciones de productos.
- Comentarios de clientes.
- Especificaciones tecnicas variables.
- Caracteristicas adicionales por categoria.

## Justificacion de uso de NoSQL

MongoDB es adecuado para esta parte de Nexus Marketplace porque permite documentos con campos flexibles y arreglos internos. Esto evita crear muchas columnas nulas o tablas auxiliares para cada tipo de especificacion tecnica.

Por ejemplo, un producto tipo celular puede tener `ram`, `almacenamiento`, `camaraMP` y `bateriaMah`, mientras que un monitor puede tener `resolucion`, `tasaRefrescoHz` y `tipoPanel`. En una base relacional, estas diferencias obligarian a crear tablas adicionales o una estructura entidad-atributo-valor mas compleja. En MongoDB se representan de forma natural como documentos.

Las resenas tambien son candidatas a NoSQL porque crecen con el tiempo, pueden incluir texto libre, etiquetas, votos de utilidad, respuestas y metadatos que no siempre estan presentes.

## Colecciones

### `productos_flexibles`

Representa la informacion flexible del producto. El identificador `productoId` puede venir de una base relacional donde este la informacion transaccional o principal del producto.

```javascript
{
  _id: ObjectId("..."),
  productoId: 1001,
  sku: "CEL-XIA-13-256",
  nombre: "Xiaomi Redmi Note 13",
  categoria: "celulares",
  marca: "Xiaomi",
  especificaciones: [
    { nombre: "ram", valor: 8, unidad: "GB", tipo: "numero" },
    { nombre: "almacenamiento", valor: 256, unidad: "GB", tipo: "numero" },
    { nombre: "bateria", valor: 5000, unidad: "mAh", tipo: "numero" },
    { nombre: "red", valor: "5G", tipo: "texto" }
  ],
  caracteristicas: ["dual sim", "carga rapida", "lector huella"],
  resumenResenas: {
    promedio: 4.6,
    total: 23,
    distribucion: { "1": 0, "2": 1, "3": 2, "4": 7, "5": 13 }
  },
  ultimasResenas: [
    {
      resenaId: ObjectId("..."),
      clienteId: 501,
      calificacion: 5,
      comentarioCorto: "Muy buen rendimiento",
      fecha: ISODate("2026-05-01T10:00:00Z")
    }
  ],
  schemaVersion: 1,
  creadoEn: ISODate("2026-05-13T00:00:00Z"),
  actualizadoEn: ISODate("2026-05-13T00:00:00Z")
}
```

### `resenas`

Almacena las resenas completas, comentarios extensos y datos que pueden crecer.

```javascript
{
  _id: ObjectId("..."),
  productoId: 1001,
  clienteId: 501,
  calificacion: 5,
  titulo: "Excelente compra",
  comentario: "El celular tiene buena bateria y buen rendimiento.",
  etiquetas: ["bateria", "rendimiento"],
  votosUtiles: 8,
  estado: "publicada",
  respuestas: [
    {
      usuario: "soporte",
      mensaje: "Gracias por tu comentario.",
      fecha: ISODate("2026-05-02T09:30:00Z")
    }
  ],
  creadoEn: ISODate("2026-05-01T10:00:00Z"),
  actualizadoEn: ISODate("2026-05-01T10:00:00Z")
}
```

## Patrones seleccionados

### 1. Patron de Atributo

Se utiliza en el arreglo `especificaciones`.

En lugar de modelar cada especificacion como un campo fijo, se guardan como documentos internos con `nombre`, `valor`, `unidad` y `tipo`. Esto facilita consultar especificaciones que cambian entre categorias.

Ejemplo:

```javascript
especificaciones: [
  { nombre: "ram", valor: 8, unidad: "GB", tipo: "numero" },
  { nombre: "almacenamiento", valor: 256, unidad: "GB", tipo: "numero" }
]
```

Ventajas para el proyecto:

- Permite productos con atributos diferentes.
- Reduce cambios de esquema cuando aparece una nueva categoria.
- Facilita crear indices sobre `especificaciones.nombre` y `especificaciones.valor`.

### 2. Patron de Subconjunto

Se utiliza con `resumenResenas` y `ultimasResenas` dentro de `productos_flexibles`, dejando las resenas completas en `resenas`.

El producto conserva solo los datos de resena mas consultados:

- Promedio.
- Total de resenas.
- Distribucion por estrellas.
- Ultimas resenas resumidas.

Ventajas para el proyecto:

- El documento del producto no crece indefinidamente.
- La pantalla de listado o detalle puede leer rapidamente el resumen.
- Las resenas completas se consultan solo cuando el usuario necesita ver el historial.

## Indices propuestos

```javascript
db.productos_flexibles.createIndex({ productoId: 1 }, { unique: true });
db.productos_flexibles.createIndex({ categoria: 1, marca: 1 });
db.productos_flexibles.createIndex({ "especificaciones.nombre": 1, "especificaciones.valor": 1 });
db.productos_flexibles.createIndex({ "resumenResenas.promedio": -1 });

db.resenas.createIndex({ productoId: 1, creadoEn: -1 });
db.resenas.createIndex({ productoId: 1, calificacion: -1 });
db.resenas.createIndex({ clienteId: 1, creadoEn: -1 });
db.resenas.createIndex({ etiquetas: 1 });
db.resenas.createIndex({ comentario: "text", titulo: "text" });
```

## Operaciones requeridas para Nexus Marketplace

### CRUD

El script `scripts/02_crud.mongodb.js` implementa:

- Create: insertar producto flexible y resena.
- Read: consultar productos y resenas.
- Update: actualizar especificaciones y comentarios.
- Delete: eliminar o cambiar estado de una resena.

### Consultas complejas

El script `scripts/03_consultas_complejas.mongodb.js` incluye:

- Productos por categoria, marca y especificaciones tecnicas.
- Productos con promedio minimo de valoracion.
- Busqueda textual en comentarios.
- Resenas con filtros por etiquetas, calificacion y fechas.

### Agregaciones

El script `scripts/04_agregaciones.mongodb.js` incluye:

- Promedio de calificacion por producto.
- Distribucion de calificaciones.
- Top productos mejor valorados por categoria.
- Etiquetas mas mencionadas en resenas.
- Recalculo del resumen de resenas para actualizar el documento del producto.
