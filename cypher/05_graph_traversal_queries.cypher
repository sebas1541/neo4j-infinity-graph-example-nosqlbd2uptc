// 05_graph_traversal_queries.cypher
// Recorridos de grafo: shortestPath, amigos-de-amigos, compañeros de trabajo.

// 1) Camino más corto entre Ana y Pedro a través de amistades
//    AMIGO_DE* significa "cualquier número de saltos por relaciones AMIGO_DE"
MATCH ruta = shortestPath(
  (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE*]-(pedro:Persona {nombre: 'Pedro'})
)
RETURN [n IN nodes(ruta) | n.nombre] AS camino,
       length(ruta)                  AS saltos;

// 2) Amigos de los amigos de Ana
//    Excluimos a la propia Ana y a sus amigos directos para mostrar sólo el 2º grado.
MATCH (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE]-(amigo:Persona)-[:AMIGO_DE]-(fof:Persona)
WHERE fof <> ana
  AND NOT (ana)-[:AMIGO_DE]-(fof)
RETURN DISTINCT fof.nombre AS amigo_de_amigo,
                fof.ciudad AS ciudad
ORDER BY amigo_de_amigo;

// 3) Compañeros de trabajo de Juan (otras personas en la misma empresa)
MATCH (juan:Persona {nombre: 'Juan'})-[:TRABAJA_EN]->(e:Empresa)<-[:TRABAJA_EN]-(colega:Persona)
WHERE colega <> juan
RETURN colega.nombre AS companero,
       e.nombre      AS empresa
ORDER BY empresa, companero;
