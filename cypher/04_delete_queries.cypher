// 04_delete_queries.cypher
// Consultas de borrado (DELETE).

// 1) Borrar UNA relación de amistad (Ana - Sara), sin tocar los nodos.
MATCH (:Persona {nombre: 'Ana'})-[r:AMIGO_DE]-(:Persona {nombre: 'Sara'})
DELETE r;

// 2) Confirmar que la relación ya no existe
MATCH (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE]-(amigo:Persona)
RETURN amigo.nombre AS amigo_actual
ORDER BY amigo_actual;

// 3) Limpieza COMPLETA del grafo (¡cuidado!).
//    DETACH DELETE borra nodo + todas sus relaciones.
//    Descomenta la línea de abajo para ejecutarla.
// MATCH (n) DETACH DELETE n;
