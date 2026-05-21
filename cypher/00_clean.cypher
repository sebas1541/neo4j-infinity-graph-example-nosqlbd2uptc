// 00_clean.cypher
// Borra todos los nodos y relaciones del grafo.
// Uso seguro: DETACH DELETE elimina también las relaciones conectadas.

MATCH (n) DETACH DELETE n;
