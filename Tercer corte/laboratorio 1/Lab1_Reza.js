// Laboratorio 1 _ Reza
// PARTE A
// A1.
db.getName();
saborya

db.getCollectionNames();
[
  "pedidos",
  "pedidos_historico",
  "clientes",
  "restaurantes",
  "productos",
  "resenas"
]

// A2.
db.restaurantes.countDocuments();
11
db.clientes.countDocuments();
9
db.productos.countDocuments();
26
db.pedidos.countDocuments();
20

// A3.

db.restaurantes.insertOne({
  _id: "R11",
  nombre: "Café Arriero",
  categoria: "Cafetería",
  ciudad: "Medellín",
  barrio: "Laureles",
  calificacion: 4.5,
  domicilio: true,
  ubicacion: {
    type: "Point",
    coordinates: [-75.5925, 6.2442]
  },
  etiquetas: ["café", "postres"]
});
{
  acknowledged: true,
  insertedId: 'R11'
}

// A4.

db.productos.insertMany([
  {
    _id: "P25",
    restaurante_id: "R11",
    nombre: "Tinto campesino",
    tipo: "bebida",
    precio: 3500,
    stock: 100,
    disponible: true,
    volumen_ml: 200
  },
  {
    _id: "P26",
    restaurante_id: "R11",
    nombre: "Torta de zanahoria",
    tipo: "postre",
    precio: 9000,
    stock: 20,
    disponible: true
  }
]);
{
  acknowledged: true,
  insertedIds: {
    '0': 'P25',
    '1': 'P26'
  }
}

// A5.
db.restaurantes.find({ ciudad: "Medellín" });
[
  {
    "_id": "R06",
    "nombre": "Verde Vivo",
    "categoria": "Vegetariana",
    "ciudad": "Medellín",
    "barrio": "El Poblado",
    "calificacion": 4.4,
    "domicilio": false,
    "ubicacion": {
      "type": "Point",
      "coordinates": [
        -75.5664,
        6.2088
      ]
    },
    "etiquetas": [
      "vegano",
      "saludable"
    ],
    "menu_vegano": true
  },
  {
    "_id": "R07",
    "nombre": "Bandeja Paisa Doña Rosa",
    "categoria": "Comida colombiana",
    "ciudad": "Medellín",
    "barrio": "Laureles",
    "calificacion": 4.7,
    "domicilio": true,
    "ubicacion": {
      "type": "Point",
      "coordinates": [
        -75.59,
        6.245
      ]
    },
    "etiquetas": [
      "bandeja paisa",
      "almuerzos"
    ]
  },
  {
    "_id": "R08",
    "nombre": "Taco Loco",
    "categoria": "Mexicana",
    "ciudad": "Medellín",
    "barrio": "Envigado",
    "calificacion": 4.1,
    "domicilio": true,
    "ubicacion": {
      "type": "Point",
      "coordinates": [
        -75.588,
        6.171
      ]
    },
    "etiquetas": [
      "tacos",
      "picante"
    ]
  },
  {
    "_id": "R11",
    "nombre": "Café Arriero",
    "categoria": "Cafetería",
    "ciudad": "Medellín",
    "barrio": "Laureles",
    "calificacion": 4.5,
    "domicilio": true,
    "ubicacion": {
      "type": "Point",
      "coordinates": [
        -75.5925,
        6.2442
      ]
    },
    "etiquetas": [
      "café",
      "postres"
    ]
  }
]

db.productos.countDocuments({ restaurante_id: "R11" });
2

// PARTE B
// B1
db.pedidos.countDocuments({ fecha: { $not: { $type: "date" } } });
0
db.productos.countDocuments({ precio: { $type: "string" } });
0

// B2.
// ¿Guardarías las reseñas dentro del documento del restaurante o en una colección propia?
// En una colección propia ('resenas'), referenciando 'restaurante_id'.
// Justificación con límite de 16 MB y patrón de acceso:
// 1) Límite de 16 MB por documento en MongoDB: si un restaurante popular acumula miles de reseñas
//    (cada una con texto, autor, fecha y hasta 4 URLs de fotos), embebidas dentro de 'restaurantes'
//    harían crecer el documento sin límite acotado y podrían superar los 16 MB.
// 2) Patrón de acceso: las reseñas crecen de forma no acotada (unbounded array) y se consultan
//    frecuentemente por separado, paginadas o filtradas por fecha/calificación (por ejemplo, "las más recientes"),
//    mientras que el documento del restaurante se lee de forma ligera para listados y fichas principales.
//    Mantenerlas en su propia colección evita reescribir documentos grandes en cada nueva reseña.
// ¿Qué datos del cliente copiarías en cada reseña y por qué?
// Copiaría un subdocumento mínimo desnormalizado con el 'id' y el 'nombre' del cliente (tal como se pide en B3).
// Esto permite mostrar quién escribió la reseña en una sola consulta sin hacer $lookup costoso contra 'clientes'
// en cada lectura de reseñas, manteniendo un tamaño muy reducido por documento.

// B3.
db.createCollection("resenas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["restaurante_id", "cliente", "calificacion", "texto", "fecha"],
      properties: {
        restaurante_id: {
          bsonType: "string",
          description: "Identificador del restaurante reseñado"
        },
        cliente: {
          bsonType: "object",
          required: ["id", "nombre"],
          properties: {
            id: { bsonType: "string" },
            nombre: { bsonType: "string" }
          }
        },
        calificacion: {
          bsonType: "int",
          minimum: 1,
          maximum: 5,
          description: "Calificación entera de 1 a 5"
        },
        texto: {
          bsonType: "string",
          minLength: 5,
          description: "Texto de la reseña con al menos 5 caracteres"
        },
        fecha: {
          bsonType: "date",
          description: "Fecha y hora de la reseña en tipo Date"
        },
        fotos: {
          bsonType: "array",
          maxItems: 4,
          items: {
            bsonType: "string"
          },
          description: "Arreglo opcional de hasta 4 URLs o textos"
        }
      }
    }
  }
});
{ ok: 1 }

// B4.
db.resenas.insertMany([
  {
    restaurante_id: "R02",
    cliente: { id: "C01", nombre: "Laura Gómez" },
    calificacion: NumberInt(5),
    texto: "El ramen llegó caliente y bien empacado",
    fecha: new Date("2026-10-15T20:10:00-05:00")
  },
  {
    restaurante_id: "R02",
    cliente: { id: "C08", nombre: "Julián Castro" },
    calificacion: NumberInt(4),
    texto: "Buen sushi, pero tardó 50 minutos",
    fecha: new Date("2026-10-16T21:30:00-05:00")
  },
  {
    restaurante_id: "R10",
    cliente: { id: "C07", nombre: "Daniela Martínez" },
    calificacion: NumberInt(5),
    texto: "La cazuela es abundante",
    fotos: [
      "https://cdn.saborya.co/r/301.jpg",
      "https://cdn.saborya.co/r/302.jpg"
    ],
    fecha: new Date("2026-10-17T13:45:00-05:00")
  },
  {
    restaurante_id: "R04",
    cliente: { id: "C03", nombre: "Valentina Ríos" },
    calificacion: NumberInt(2),
    texto: "Las papas llegaron frías",
    fecha: new Date("2026-10-18T19:05:00-05:00")
  }
]);
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('6b066df9e0f3eb8529799c98'),
    '1': ObjectId('6b066df9e0f3eb8529799c99'),
    '2': ObjectId('6b066df9e0f3eb8529799c9a'),
    '3': ObjectId('6b066df9e0f3eb8529799c9b')
  }
}
// B5.
db.resenas.insertOne({
  restaurante_id: "R01",
  cliente: { id: "C01", nombre: "Laura Gómez" },
  calificacion: NumberInt(6),
  texto: "Excelente servicio y comida",
  fecha: new Date("2026-10-19T12:00:00-05:00")
});
MongoServerError: Document failed validation
// B6.
db.resenas.find({ "cliente.id": "C01" });
[
  {
    "_id": "6b066df9e0f3eb8529799c98",
    "restaurante_id": "R02",
    "cliente": {
      "id": "C01",
      "nombre": "Laura Gómez"
    },
    "calificacion": 5,
    "texto": "El ramen llegó caliente y bien empacado",
    "fecha": "2026-10-16T01:10:00.000Z"
  }
]

db.resenas.find({ fotos: { $exists: true, $ne: [] } });
[
  {
    "_id": "6b066df9e0f3eb8529799c9a",
    "restaurante_id": "R10",
    "cliente": {
      "id": "C07",
      "nombre": "Daniela Martínez"
    },
    "calificacion": 5,
    "texto": "La cazuela es abundante",
    "fotos": [
      "https://cdn.saborya.co/r/301.jpg",
      "https://cdn.saborya.co/r/302.jpg"
    ],
    "fecha": "2026-10-17T18:45:00.000Z"
  }
]

// B7.
db.restaurantes.updateOne(
  { _id: "R02" },
  {
    $set: {
      resumen_resenas: {
        promedio: 4.5,
        total: 2
      }
    }
  }
);
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 0,
  upsertedCount: 0
}
// B8.
db.resenas.distinct("restaurante_id");
[
  "R02",
  "R10"
]

// PARTE C
// C1.
db.productos.find({ tipo: "plato", disponible: true, stock: { $lt: 20 } }, { _id: 0, nombre: 1, stock: 1 }).sort({ stock: 1 });
[
  {
    "nombre": "Cazuela de mariscos",
    "stock": 10
  },
  {
    "nombre": "Picada para dos",
    "stock": 12
  },
  {
    "nombre": "Arroz con coco y pescado",
    "stock": 14
  },
  {
    "nombre": "Combo Sake",
    "stock": 15
  },
  {
    "nombre": "Costillas BBQ",
    "stock": 15
  },
  {
    "nombre": "Hamburguesa de lentejas",
    "stock": 18
  }
]

// C2.
db.pedidos.find({ total: { $gte: 50000, $lte: 80000 }, metodo_pago: { $in: ["efectivo", "nequi"] } }, { _id: 0, total: 1, metodo_pago: 1 });
[
  {
    "metodo_pago": "nequi",
    "total": 60000
  },
  {
    "metodo_pago": "efectivo",
    "total": 76000
  },
  {
    "metodo_pago": "nequi",
    "total": 70000
  },
  {
    "metodo_pago": "efectivo",
    "total": 64000
  },
  {
    "metodo_pago": "nequi",
    "total": 67000
  },
  {
    "metodo_pago": "efectivo",
    "total": 78000
  }
]

// C3.
db.restaurantes.find({ ciudad: "Bogotá" }, { _id: 0, nombre: 1, calificacion: 1 }).sort({ calificacion: -1, nombre: 1 }).limit(3);
[
  {
    "nombre": "Sushi Nikko",
    "calificacion": 4.8
  },
  {
    "nombre": "Arepas La 19",
    "calificacion": 4.6
  },
  {
    "nombre": "Ajiaco & Co",
    "calificacion": 4.5
  }
]

// C4.
db.clientes.find({ ciudad: "Bogotá", puntos: { $gt: 100 } }, { _id: 0, nombre: 1, ciudad: 1, puntos: 1 });
[
  {
    "nombre": "Laura Gómez",
    "ciudad": "Bogotá",
    "puntos": 120
  },
  {
    "nombre": "Andrés Rojas",
    "ciudad": "Bogotá",
    "puntos": 340
  },
  {
    "nombre": "Julián Castro",
    "ciudad": "Bogotá",
    "puntos": 600
  }
]

// C5.
db.pedidos.find({ fecha: { $gte: new Date("2026-10-12T00:00:00-05:00"), $lte: new Date("2026-10-14T23:59:59.999-05:00") }, estado: { $ne: "entregado" } }, { _id: 0, fecha: 1, estado: 1, total: 1 });
[
  {
    "fecha": "2026-10-12T23:30:00.000Z",
    "estado": "en_camino",
    "total": 30000
  },
  {
    "fecha": "2026-10-12T18:00:00.000Z",
    "estado": "pendiente",
    "total": 34000
  },
  {
    "fecha": "2026-10-14T01:20:00.000Z",
    "estado": "en_camino",
    "total": 82000
  },
  {
    "fecha": "2026-10-14T02:00:00.000Z",
    "estado": "en_camino",
    "total": 103000
  },
  {
    "fecha": "2026-10-15T00:10:00.000Z",
    "estado": "cancelado",
    "total": 48000
  }
]

// C6.
db.pedidos.find({ items: { $elemMatch: { precio: { $lt: 10000 }, cantidad: { $gte: 2 } } } }, { _id: 0, items: 1 });
[
  {
    "items": [
      {
        "producto_id": "P04",
        "nombre": "Combo Sake",
        "precio": 41000,
        "cantidad": 1
      },
      {
        "producto_id": "P06",
        "nombre": "Té verde",
        "precio": 7000,
        "cantidad": 2
      }
    ]
  },
  {
    "items": [
      {
        "producto_id": "P01",
        "nombre": "Arepa de choclo con queso",
        "precio": 9500,
        "cantidad": 2
      },
      {
        "producto_id": "P03",
        "nombre": "Jugo de lulo",
        "precio": 6000,
        "cantidad": 1
      }
    ]
  },
  {
    "items": [
      {
        "producto_id": "P10",
        "nombre": "Hamburguesa clásica",
        "precio": 22000,
        "cantidad": 2
      },
      {
        "producto_id": "P11",
        "nombre": "Papas a la francesa",
        "precio": 8000,
        "cantidad": 2
      }
    ]
  },
  {
    "items": [
      {
        "producto_id": "P22",
        "nombre": "Cazuela de mariscos",
        "precio": 52000,
        "cantidad": 1
      },
      {
        "producto_id": "P24",
        "nombre": "Limonada de coco",
        "precio": 9000,
        "cantidad": 2
      }
    ]
  },
  {
    "items": [
      {
        "producto_id": "P02",
        "nombre": "Arepa rellena de carne",
        "precio": 14000,
        "cantidad": 1
      },
      {
        "producto_id": "P03",
        "nombre": "Jugo de lulo",
        "precio": 6000,
        "cantidad": 2
      }
    ]
  }
]
//C6 ($elemMatch vs. sin $elemMatch): Con $elemMatch sobre items, MongoDB exige que un mismo objeto del arreglo items cumpla precio < 10000 y cantidad >= 2 al mismo tiempo. Sin $elemMatch, la consulta "items.precio": { $lt: 10000 }, "items.cantidad": { $gte: 2 } puede satisfacerse si un ítem tiene precio menor a 10.000 y otro ítem distinto del mismo pedido tiene cantidad mayor o igual a 2.
// C7.
db.productos.find({}, { _id: 0, nombre: 1, precio: 1 }).sort({ precio: -1, _id: 1 }).skip(6).limit(6);
[
  {
    "nombre": "Ramen tonkotsu",
    "precio": 36000
  },
  {
    "nombre": "Bandeja paisa",
    "precio": 36000
  },
  {
    "nombre": "Pizza hawaiana mediana",
    "precio": 32000
  },
  {
    "nombre": "Lasaña boloñesa",
    "precio": 29000
  },
  {
    "nombre": "Ajiaco santafereño",
    "precio": 28000
  },
  {
    "nombre": "Bowl de quinua",
    "precio": 26000
  }
]

// C8.
db.restaurantes.find({ $or: [{ horario: { $exists: true } }, { menu_vegano: { $exists: true } }] }, { _id: 0, nombre: 1, horario: 1, menu_vegano: 1 });
[
  {
    "nombre": "Sushi Nikko",
    "horario": {
      "apertura": "12:00",
      "cierre": "22:00"
    }
  },
  {
    "nombre": "Verde Vivo",
    "menu_vegano": true
  }
]

// PARTE D
// D1.
db.productos.updateMany(
  { restaurante_id: "R07", tipo: "plato" },
  { $inc: { precio: 1000 } }
);
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
//D1 (updateMany en R07): matchedCount indica cuántos documentos cumplieron el filtro, modifiedCount cuántos cambiaron realmente y upsertedCount cuántos se insertaron por upsert (0 aquí). Aunque R07 tenga dos productos en total, solo uno de ellos cumple el filtro tipo: "plato" (el otro tiene otro tipo de producto, como bebida o postre).

// D2.
db.pedidos.updateOne(
  { _id: "PD018", estado: "pendiente" },
  { $set: { estado: "en_camino" } }
);
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 0,
  modifiedCount: 0,
  upsertedCount: 0
}
db.pedidos.updateOne(
  { _id: "PD018", estado: "pendiente" },
  { $set: { estado: "en_camino" } }
);
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 0,
  modifiedCount: 0,
  upsertedCount: 0
}
//D2 (PD018 ejecutado dos veces): En la primera ejecución, PD018 está "pendiente", así que coincide (matchedCount: 1) y pasa a "en_camino" (modifiedCount: 1, upsertedCount: 0). En la segunda ejecución, el filtro busca _id: "PD018" con estado: "pendiente", pero ya vale "en_camino", por lo que no hay coincidencia (matchedCount: 0, modifiedCount: 0, upsertedCount: 0).

// D3.
db.clientes.updateOne(
  { _id: "C03" },
  { $addToSet: { preferencias: "japonesa" } }
);
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 0,
  upsertedCount: 0
}
db.clientes.updateOne(
  { _id: "C03" },
  { $addToSet: { preferencias: "japonesa" } }
);
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 0,
  upsertedCount: 0
}
//D3 ($addToSet en C03 ejecutado dos veces): Con $addToSet, "japonesa" solo se añade si aún no existe en preferencias. En ambas ejecuciones matchedCount es 1 (existe C03), pero modifiedCount es 1 en la primera (agrega "japonesa") y 0 en la segunda (ya estaba presente y no se duplica), con upsertedCount: 0 en ambas.

// D4.
db.clientes.updateOne(
  { email: "natalia.suarez@example.com" },
  {
    $setOnInsert: {
      _id: "C09",
      nombre: "Natalia Suárez",
      email: "natalia.suarez@example.com",
      ciudad: "Medellín",
      puntos: 0,
      direcciones: []
    }
  },
  { upsert: true }
);
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 0,
  upsertedCount: 0
}

// D5.
db.productos.updateOne(
  { _id: "P06" },
  { $unset: { volumen_ml: "" } }
);
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 0,
  upsertedCount: 0
}

// D6.
db.resenas.countDocuments({ calificacion: { $lt: 3 } });
1
db.resenas.countDocuments({ calificacion: { $lt: 3 } });


// D7.
db.pedidos.countDocuments({ ciudad: "Medellín", estado: "cancelado" });
0
db.pedidos.deleteMany({ ciudad: "Medellín", estado: "cancelado" });
{
  acknowledged: true,
  deletedCount: 0
}

// D8.
db.restaurantes.countDocuments();
11
db.clientes.countDocuments();
9
db.productos.countDocuments();
26
db.resenas.countDocuments();
3
