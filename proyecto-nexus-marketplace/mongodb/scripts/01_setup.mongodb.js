use("nexus_marketplace_nosql");

db.productos_flexibles.drop();
db.resenas.drop();

db.createCollection("productos_flexibles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["productoId", "sku", "nombre", "categoria", "especificaciones", "schemaVersion"],
      properties: {
        productoId: { bsonType: "int" },
        sku: { bsonType: "string" },
        nombre: { bsonType: "string" },
        categoria: { bsonType: "string" },
        marca: { bsonType: "string" },
        especificaciones: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["nombre", "valor", "tipo"],
            properties: {
              nombre: { bsonType: "string" },
              valor: {},
              unidad: { bsonType: "string" },
              tipo: { enum: ["numero", "texto", "booleano"] }
            }
          }
        },
        schemaVersion: { bsonType: "int" }
      }
    }
  }
});

db.createCollection("resenas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["productoId", "clienteId", "calificacion", "comentario", "estado", "creadoEn"],
      properties: {
        productoId: { bsonType: "int" },
        clienteId: { bsonType: "int" },
        calificacion: { bsonType: "int", minimum: 1, maximum: 5 },
        titulo: { bsonType: "string" },
        comentario: { bsonType: "string" },
        etiquetas: {
          bsonType: "array",
          items: { bsonType: "string" }
        },
        votosUtiles: { bsonType: "int" },
        estado: { enum: ["publicada", "oculta", "eliminada"] },
        creadoEn: { bsonType: "date" },
        actualizadoEn: { bsonType: "date" }
      }
    }
  }
});

db.productos_flexibles.insertMany([
  {
        productoId: NumberInt(1001),
    sku: "CEL-XIA-13-256",
    nombre: "Xiaomi Redmi Note 13",
    categoria: "celulares",
    marca: "Xiaomi",
    especificaciones: [
      { nombre: "ram", valor: NumberInt(8), unidad: "GB", tipo: "numero" },
      { nombre: "almacenamiento", valor: NumberInt(256), unidad: "GB", tipo: "numero" },
      { nombre: "bateria", valor: NumberInt(5000), unidad: "mAh", tipo: "numero" },
      { nombre: "red", valor: "5G", tipo: "texto" }
    ],
    caracteristicas: ["dual sim", "carga rapida", "lector huella"],
    resumenResenas: {
      promedio: 0,
      total: NumberInt(0),
      distribucion: { "1": NumberInt(0), "2": NumberInt(0), "3": NumberInt(0), "4": NumberInt(0), "5": NumberInt(0) }
    },
    ultimasResenas: [],
    schemaVersion: NumberInt(1),
    creadoEn: new Date("2026-05-13T00:00:00Z"),
    actualizadoEn: new Date("2026-05-13T00:00:00Z")
  },
  {
    productoId: NumberInt(1002),
    sku: "LAP-LEN-I5-16",
    nombre: "Lenovo IdeaPad Slim 5",
    categoria: "portatiles",
    marca: "Lenovo",
    especificaciones: [
      { nombre: "procesador", valor: "Intel Core i5", tipo: "texto" },
      { nombre: "ram", valor: NumberInt(16), unidad: "GB", tipo: "numero" },
      { nombre: "almacenamiento", valor: NumberInt(512), unidad: "GB SSD", tipo: "numero" },
      { nombre: "pantalla", valor: NumberInt(14), unidad: "pulgadas", tipo: "numero" }
    ],
    caracteristicas: ["teclado retroiluminado", "wifi 6", "carga usb-c"],
    resumenResenas: {
      promedio: 0,
      total: NumberInt(0),
      distribucion: { "1": NumberInt(0), "2": NumberInt(0), "3": NumberInt(0), "4": NumberInt(0), "5": NumberInt(0) }
    },
    ultimasResenas: [],
    schemaVersion: NumberInt(1),
    creadoEn: new Date("2026-05-13T00:00:00Z"),
    actualizadoEn: new Date("2026-05-13T00:00:00Z")
  },
  {
    productoId: NumberInt(1003),
    sku: "MON-SAM-27-144",
    nombre: "Samsung Odyssey 27",
    categoria: "monitores",
    marca: "Samsung",
    especificaciones: [
      { nombre: "tamano", valor: NumberInt(27), unidad: "pulgadas", tipo: "numero" },
      { nombre: "resolucion", valor: "QHD", tipo: "texto" },
      { nombre: "tasaRefresco", valor: NumberInt(144), unidad: "Hz", tipo: "numero" },
      { nombre: "tipoPanel", valor: "VA", tipo: "texto" }
    ],
    caracteristicas: ["freesync", "modo juego", "curvo"],
    resumenResenas: {
      promedio: 0,
      total: NumberInt(0),
      distribucion: { "1": NumberInt(0), "2": NumberInt(0), "3": NumberInt(0), "4": NumberInt(0), "5": NumberInt(0) }
    },
    ultimasResenas: [],
    schemaVersion: NumberInt(1),
    creadoEn: new Date("2026-05-13T00:00:00Z"),
    actualizadoEn: new Date("2026-05-13T00:00:00Z")
  }
]);

const resenasIniciales = [
  {
    productoId: NumberInt(1001),
    clienteId: NumberInt(501),
    calificacion: NumberInt(5),
    titulo: "Excelente compra",
    comentario: "El celular tiene buena bateria y buen rendimiento.",
    etiquetas: ["bateria", "rendimiento"],
    votosUtiles: NumberInt(8),
    estado: "publicada",
    respuestas: [],
    creadoEn: new Date("2026-05-01T10:00:00Z"),
    actualizadoEn: new Date("2026-05-01T10:00:00Z")
  },
  {
    productoId: NumberInt(1001),
    clienteId: NumberInt(502),
    calificacion: NumberInt(4),
    titulo: "Buen equipo",
    comentario: "La camara funciona bien y la bateria dura bastante.",
    etiquetas: ["camara", "bateria"],
    votosUtiles: NumberInt(3),
    estado: "publicada",
    respuestas: [],
    creadoEn: new Date("2026-05-03T12:30:00Z"),
    actualizadoEn: new Date("2026-05-03T12:30:00Z")
  },
  {
    productoId: NumberInt(1002),
    clienteId: NumberInt(503),
    calificacion: NumberInt(5),
    titulo: "Rapido para estudiar",
    comentario: "El portatil abre rapido los programas y la pantalla es comoda.",
    etiquetas: ["rendimiento", "pantalla"],
    votosUtiles: NumberInt(6),
    estado: "publicada",
    respuestas: [],
    creadoEn: new Date("2026-05-04T08:15:00Z"),
    actualizadoEn: new Date("2026-05-04T08:15:00Z")
  },
  {
    productoId: NumberInt(1003),
    clienteId: NumberInt(504),
    calificacion: NumberInt(3),
    titulo: "Aceptable",
    comentario: "La imagen es buena, pero esperaba mejor soporte ergonomico.",
    etiquetas: ["imagen", "ergonomia"],
    votosUtiles: NumberInt(2),
    estado: "publicada",
    respuestas: [],
    creadoEn: new Date("2026-05-05T16:45:00Z"),
    actualizadoEn: new Date("2026-05-05T16:45:00Z")
  }
];

db.resenas.insertMany(resenasIniciales);

db.productos_flexibles.createIndex({ productoId: 1 }, { unique: true });
db.productos_flexibles.createIndex({ categoria: 1, marca: 1 });
db.productos_flexibles.createIndex({ "especificaciones.nombre": 1, "especificaciones.valor": 1 });
db.productos_flexibles.createIndex({ "resumenResenas.promedio": -1 });

db.resenas.createIndex({ productoId: 1, creadoEn: -1 });
db.resenas.createIndex({ productoId: 1, calificacion: -1 });
db.resenas.createIndex({ clienteId: 1, creadoEn: -1 });
db.resenas.createIndex({ etiquetas: 1 });
db.resenas.createIndex({ comentario: "text", titulo: "text" });

print("Base nexus_marketplace_nosql creada para Nexus Marketplace con colecciones, datos iniciales e indices.");
