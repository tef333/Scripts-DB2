use("nexus_marketplace_nosql");

print("1. Promedio de calificacion y total de resenas por producto");
printjson(
  db.resenas.aggregate([
    { $match: { estado: "publicada" } },
    {
      $group: {
        _id: "$productoId",
        promedio: { $avg: "$calificacion" },
        total: { $sum: 1 },
        votosUtiles: { $sum: "$votosUtiles" }
      }
    },
    {
      $lookup: {
        from: "productos_flexibles",
        localField: "_id",
        foreignField: "productoId",
        as: "producto"
      }
    },
    { $unwind: "$producto" },
    {
      $project: {
        _id: 0,
        productoId: "$_id",
        nombre: "$producto.nombre",
        categoria: "$producto.categoria",
        promedio: { $round: ["$promedio", 2] },
        total: 1,
        votosUtiles: 1
      }
    },
    { $sort: { promedio: -1, total: -1 } }
  ]).toArray()
);

print("2. Distribucion de calificaciones por producto");
printjson(
  db.resenas.aggregate([
    { $match: { estado: "publicada" } },
    {
      $group: {
        _id: {
          productoId: "$productoId",
          calificacion: "$calificacion"
        },
        cantidad: { $sum: 1 }
      }
    },
    {
      $group: {
        _id: "$_id.productoId",
        distribucion: {
          $push: {
            calificacion: "$_id.calificacion",
            cantidad: "$cantidad"
          }
        },
        total: { $sum: "$cantidad" }
      }
    },
    { $sort: { _id: 1 } }
  ]).toArray()
);

print("3. Top productos mejor valorados por categoria");
printjson(
  db.resenas.aggregate([
    { $match: { estado: "publicada" } },
    {
      $group: {
        _id: "$productoId",
        promedio: { $avg: "$calificacion" },
        total: { $sum: 1 }
      }
    },
    { $match: { total: { $gte: 1 } } },
    {
      $lookup: {
        from: "productos_flexibles",
        localField: "_id",
        foreignField: "productoId",
        as: "producto"
      }
    },
    { $unwind: "$producto" },
    {
      $setWindowFields: {
        partitionBy: "$producto.categoria",
        sortBy: { promedio: -1, total: -1 },
        output: {
          posicionCategoria: { $rank: {} }
        }
      }
    },
    { $match: { posicionCategoria: { $lte: 3 } } },
    {
      $project: {
        _id: 0,
        productoId: "$_id",
        nombre: "$producto.nombre",
        categoria: "$producto.categoria",
        promedio: { $round: ["$promedio", 2] },
        total: 1,
        posicionCategoria: 1
      }
    }
  ]).toArray()
);

print("4. Etiquetas mas mencionadas en resenas publicadas");
printjson(
  db.resenas.aggregate([
    { $match: { estado: "publicada" } },
    { $unwind: "$etiquetas" },
    {
      $group: {
        _id: "$etiquetas",
        menciones: { $sum: 1 },
        promedioCalificacion: { $avg: "$calificacion" }
      }
    },
    {
      $project: {
        _id: 0,
        etiqueta: "$_id",
        menciones: 1,
        promedioCalificacion: { $round: ["$promedioCalificacion", 2] }
      }
    },
    { $sort: { menciones: -1, etiqueta: 1 } }
  ]).toArray()
);

print("5. Recalcular resumen de resenas y actualizar productos_flexibles");
const resumenes = db.resenas.aggregate([
  { $match: { estado: "publicada" } },
  {
    $group: {
      _id: {
        productoId: "$productoId",
        calificacion: "$calificacion"
      },
      cantidad: { $sum: 1 }
    }
  },
  {
    $group: {
      _id: "$_id.productoId",
      promedioNumerador: {
        $sum: { $multiply: ["$_id.calificacion", "$cantidad"] }
      },
      total: { $sum: "$cantidad" },
      pares: {
        $push: {
          k: { $toString: "$_id.calificacion" },
          v: "$cantidad"
        }
      }
    }
  },
  {
    $project: {
      productoId: "$_id",
      promedio: { $round: [{ $divide: ["$promedioNumerador", "$total"] }, 2] },
      total: 1,
      distribucionCalculada: { $arrayToObject: "$pares" }
    }
  }
]).toArray();

resumenes.forEach((resumen) => {
  const distribucion = Object.assign(
    { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0 },
    resumen.distribucionCalculada
  );

  const ultimasResenas = db.resenas.find(
    { productoId: resumen.productoId, estado: "publicada" },
    { clienteId: 1, calificacion: 1, comentario: 1, creadoEn: 1 }
  ).sort({ creadoEn: -1 }).limit(3).toArray().map((resena) => ({
    resenaId: resena._id,
    clienteId: resena.clienteId,
    calificacion: resena.calificacion,
    comentarioCorto: resena.comentario.substring(0, 80),
    fecha: resena.creadoEn
  }));

  db.productos_flexibles.updateOne(
    { productoId: resumen.productoId },
    {
      $set: {
        resumenResenas: {
          promedio: resumen.promedio,
          total: resumen.total,
          distribucion
        },
        ultimasResenas,
        actualizadoEn: new Date()
      }
    }
  );
});

printjson(db.productos_flexibles.find({}, {
  productoId: 1,
  nombre: 1,
  resumenResenas: 1,
  ultimasResenas: 1
}).toArray());
