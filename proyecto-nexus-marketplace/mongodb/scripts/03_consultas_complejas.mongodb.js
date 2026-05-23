use("nexus_marketplace_nosql");

print("1. Celulares Xiaomi con minimo 8 GB de RAM y almacenamiento desde 128 GB");
printjson(
  db.productos_flexibles.find({
    categoria: "celulares",
    marca: "Xiaomi",
    $and: [
      {
        especificaciones: {
          $elemMatch: {
            nombre: "ram",
            valor: { $gte: 8 },
            unidad: "GB"
          }
        }
      },
      {
        especificaciones: {
          $elemMatch: {
            nombre: "almacenamiento",
            valor: { $gte: 128 }
          }
        }
      }
    ]
  }).toArray()
);

print("2. Productos con caracteristicas especificas y promedio de resenas mayor o igual a 4");
printjson(
  db.productos_flexibles.find({
    caracteristicas: { $in: ["carga rapida", "wifi 6"] },
    "resumenResenas.promedio": { $gte: 4 }
  }, {
    nombre: 1,
    categoria: 1,
    caracteristicas: 1,
    resumenResenas: 1
  }).sort({ "resumenResenas.promedio": -1 }).toArray()
);

print("3. Busqueda textual en resenas que mencionan bateria o rendimiento");
printjson(
  db.resenas.find(
    {
      $text: { $search: "bateria rendimiento" },
      estado: "publicada"
    },
    {
      score: { $meta: "textScore" },
      productoId: 1,
      titulo: 1,
      comentario: 1,
      calificacion: 1
    }
  ).sort({ score: { $meta: "textScore" } }).toArray()
);

print("4. Resenas publicadas con calificacion alta, etiqueta y rango de fechas");
printjson(
  db.resenas.find({
    estado: "publicada",
    calificacion: { $gte: 4 },
    etiquetas: { $in: ["bateria", "rendimiento"] },
    creadoEn: {
      $gte: new Date("2026-05-01T00:00:00Z"),
      $lte: new Date("2026-05-31T23:59:59Z")
    }
  }).sort({ votosUtiles: -1, creadoEn: -1 }).toArray()
);

print("5. Productos que tienen una especificacion numerica dentro de un rango dinamico");
printjson(
  db.productos_flexibles.find({
    especificaciones: {
      $elemMatch: {
        tipo: "numero",
        nombre: { $in: ["ram", "tasaRefresco", "autonomia"] },
        valor: { $gte: 8 }
      }
    }
  }, {
    productoId: 1,
    nombre: 1,
    categoria: 1,
    especificaciones: 1
  }).toArray()
);
