use("nexus_marketplace_nosql");

print("CREATE: insertar un producto flexible");
db.productos_flexibles.insertOne({
  productoId: NumberInt(1004),
  sku: "AUD-SON-WH720",
  nombre: "Sony WH-CH720N",
  categoria: "audio",
  marca: "Sony",
  especificaciones: [
    { nombre: "tipo", valor: "over-ear", tipo: "texto" },
    { nombre: "cancelacionRuido", valor: true, tipo: "booleano" },
    { nombre: "autonomia", valor: NumberInt(35), unidad: "horas", tipo: "numero" }
  ],
  caracteristicas: ["bluetooth", "microfono integrado", "carga rapida"],
  resumenResenas: {
    promedio: 0,
    total: NumberInt(0),
    distribucion: { "1": NumberInt(0), "2": NumberInt(0), "3": NumberInt(0), "4": NumberInt(0), "5": NumberInt(0) }
  },
  ultimasResenas: [],
  schemaVersion: NumberInt(1),
  creadoEn: new Date(),
  actualizadoEn: new Date()
});

print("CREATE: insertar una resena");
const nuevaResena = {
  productoId: NumberInt(1004),
  clienteId: NumberInt(505),
  calificacion: NumberInt(5),
  titulo: "Muy buen sonido",
  comentario: "La cancelacion de ruido funciona bien y la bateria dura bastante.",
  etiquetas: ["sonido", "bateria", "cancelacion"],
  votosUtiles: NumberInt(0),
  estado: "publicada",
  respuestas: [],
  creadoEn: new Date(),
  actualizadoEn: new Date()
};

const resultadoResena = db.resenas.insertOne(nuevaResena);

db.productos_flexibles.updateOne(
  { productoId: nuevaResena.productoId },
  {
    $push: {
      ultimasResenas: {
        $each: [
          {
            resenaId: resultadoResena.insertedId,
            clienteId: nuevaResena.clienteId,
            calificacion: nuevaResena.calificacion,
            comentarioCorto: nuevaResena.comentario.substring(0, 80),
            fecha: nuevaResena.creadoEn
          }
        ],
        $sort: { fecha: -1 },
        $slice: 3
      }
    },
    $set: { actualizadoEn: new Date() }
  }
);

print("READ: consultar productos de audio con cancelacion de ruido");
printjson(
  db.productos_flexibles.find({
    categoria: "audio",
    especificaciones: {
      $elemMatch: {
        nombre: "cancelacionRuido",
        valor: true
      }
    }
  }).toArray()
);

print("READ: consultar resenas publicadas de un producto");
printjson(
  db.resenas.find(
    { productoId: 1004, estado: "publicada" },
    { comentario: 1, calificacion: 1, etiquetas: 1, creadoEn: 1 }
  ).sort({ creadoEn: -1 }).toArray()
);

print("UPDATE: agregar nueva especificacion tecnica al producto");
db.productos_flexibles.updateOne(
  { productoId: 1004 },
  {
    $push: {
      especificaciones: {
        nombre: "peso",
        valor: NumberInt(192),
        unidad: "g",
        tipo: "numero"
      }
    },
    $set: { actualizadoEn: new Date() }
  }
);

print("UPDATE: editar comentario de una resena");
db.resenas.updateOne(
  { _id: resultadoResena.insertedId },
  {
    $set: {
      comentario: "La cancelacion de ruido funciona muy bien y la bateria dura bastante.",
      actualizadoEn: new Date()
    },
    $addToSet: { etiquetas: "comodidad" }
  }
);

print("DELETE LOGICO: marcar una resena como eliminada sin perder historial");
db.resenas.updateOne(
  { _id: resultadoResena.insertedId },
  {
    $set: {
      estado: "eliminada",
      actualizadoEn: new Date()
    }
  }
);

print("DELETE FISICO DE EJEMPLO: eliminar productos de prueba de audio");
db.productos_flexibles.deleteOne({ productoId: 1004 });

print("CRUD ejecutado.");
