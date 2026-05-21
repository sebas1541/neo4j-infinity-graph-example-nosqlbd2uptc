// 03_update_queries.cypher
// Consultas de actualización (UPDATE) y MERGE.

// 1) Actualizar la profesión y edad de Ana con SET
MATCH (ana:Persona {nombre: 'Ana'})
SET ana.profesion = 'Data Engineer Senior',
    ana.edad      = 29
RETURN ana.nombre AS nombre, ana.edad AS edad, ana.profesion AS profesion;

// 2) MERGE: crear el nodo Ciudad sólo si no existe, y conectar a Ana
MERGE (bog:Ciudad {nombre: 'Bogotá'})
WITH bog
MATCH (ana:Persona {nombre: 'Ana'})
MERGE (ana)-[:VIVE_EN]->(bog)
RETURN ana.nombre AS persona, bog.nombre AS ciudad;

// 3) MERGE genérico: para cada Persona, asegurar que existe su Ciudad
//    y conectarla con VIVE_EN (idempotente: se puede correr varias veces).
MATCH (p:Persona)
MERGE (c:Ciudad {nombre: p.ciudad})
MERGE (p)-[:VIVE_EN]->(c)
RETURN p.nombre AS persona, c.nombre AS ciudad
ORDER BY ciudad, persona;
