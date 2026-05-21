// 02_read_queries.cypher
// Consultas básicas de lectura (READ).

// 1) Mostrar todos los nodos del grafo
MATCH (n) RETURN n;

// 2) Contar nodos por tipo (Persona / Empresa)
MATCH (n)
RETURN labels(n)[0] AS tipo, count(*) AS total
ORDER BY tipo;

// 3) Amigos de Ana (sin importar dirección de la relación)
MATCH (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE]-(amigo:Persona)
RETURN amigo.nombre AS amigo, amigo.ciudad AS ciudad
ORDER BY amigo;

// 4) Personas agrupadas por ciudad
MATCH (p:Persona)
RETURN p.ciudad AS ciudad, collect(p.nombre) AS personas, count(*) AS total
ORDER BY ciudad;

// 5) Trabajadores por empresa (con su rol)
MATCH (p:Persona)-[t:TRABAJA_EN]->(e:Empresa)
RETURN e.nombre AS empresa,
       collect({nombre: p.nombre, rol: t.rol}) AS empleados
ORDER BY empresa;
