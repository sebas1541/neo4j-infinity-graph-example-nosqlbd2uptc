# Guion de demostración en vivo — Neo4j

Tiempo estimado: 8–12 minutos.
Mantén el `quick_cheatsheet.md` abierto en otra pestaña por si te
preguntan sintaxis.

> Antes de empezar: corre `./scripts/start.sh` (o asegúrate de que
> Neo4j ya esté arriba). No cargues el dataset todavía: lo hacemos
> en vivo en el paso 4.

---

## 1. Abrir Neo4j Browser

- En el navegador: <http://localhost:7474>
- **Decir:** "Neo4j viene con una interfaz web propia, no necesito
  instalar nada en mi máquina más allá de Docker."

## 2. Login

- Connect URL: `bolt://localhost:7687`
- Usuario: `neo4j`
- Password: `clase2026`
- **Decir:** "Me conecto por el protocolo Bolt, que es el protocolo
  binario de Neo4j. Es lo que usaríamos también desde Python, Java,
  JavaScript, etc."

## 3. Explicar nodos y relaciones

- **Decir:** "En una base relacional tendría tablas `Persona`,
  `Empresa`, `Amistad`, `Trabaja_En`, y muchos `JOIN`. En Neo4j tengo
  **nodos** con **etiquetas** (`:Persona`, `:Empresa`) y
  **relaciones** tipadas (`:AMIGO_DE`, `:TRABAJA_EN`) con propiedades
  como `desde` o `rol`. Las relaciones son ciudadanos de primera
  clase, no filas en una tabla intermedia."

## 4. Cargar el dataset (CREATE)

Pegar en el editor del Browser el contenido de
`cypher/01_create_demo_graph.cypher` y presionar **Play** (`Ctrl+Enter`).

- **Decir:** "Con un solo `CREATE` describimos 22 personas, 4 empresas
  y todas sus relaciones. La sintaxis es básicamente un dibujo del
  grafo: `(nodo)-[:RELACION]->(nodo)`."

## 5. Mostrar el grafo completo

```cypher
MATCH (n) RETURN n;
```

- **Decir:** "El Browser dibuja el grafo automáticamente. Puedo
  arrastrar los nodos, hacer doble click para expandir vecinos, y
  ver las propiedades en el panel lateral."

## 6. Amigos de Ana

```cypher
MATCH (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE]-(amigo:Persona)
RETURN amigo.nombre AS amigo, amigo.ciudad AS ciudad;
```

- **Decir:** "Fíjense que uso `-[:AMIGO_DE]-` sin flecha. La amistad
  es simétrica, así que recorro la relación en cualquier dirección.
  En SQL esto sería un JOIN con un `OR` feo entre dos columnas."

## 7. Compañeros de trabajo de Juan

```cypher
MATCH (juan:Persona {nombre: 'Juan'})-[:TRABAJA_EN]->(e:Empresa)<-[:TRABAJA_EN]-(colega:Persona)
WHERE colega <> juan
RETURN colega.nombre AS companero, e.nombre AS empresa;
```

- **Decir:** "Esto es un patrón clásico de 'colegas': Juan trabaja en
  X, alguien más también trabaja en X. En SQL es un self-join. En
  Cypher es literalmente dibujar el patrón."

## 8. Camino más corto Ana → Pedro

```cypher
MATCH ruta = shortestPath(
  (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE*]-(pedro:Persona {nombre: 'Pedro'})
)
RETURN [n IN nodes(ruta) | n.nombre] AS camino, length(ruta) AS saltos;
```

- **Decir:** "Esta es la **killer feature** de los grafos. Ana no es
  amiga directa de Pedro, pero hay un camino de amistades entre
  ellos. `shortestPath` lo encuentra en milisegundos. En SQL tendría
  que hacer recursión con CTEs y se vuelve impráctico con varios
  saltos."

## 9. Actualizar la profesión de Ana (UPDATE)

```cypher
MATCH (ana:Persona {nombre: 'Ana'})
SET ana.profesion = 'Data Engineer Senior', ana.edad = 29
RETURN ana;
```

- **Decir:** "Las propiedades de los nodos son flexibles, no hay
  esquema rígido. Acabo de agregar `profesion` aunque ningún otro
  nodo la tenga."

## 10. Borrar una relación (DELETE)

```cypher
MATCH (:Persona {nombre: 'Ana'})-[r:AMIGO_DE]-(:Persona {nombre: 'Sara'})
DELETE r;
```

Verificar:

```cypher
MATCH (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE]-(amigo:Persona)
RETURN amigo.nombre;
```

- **Decir:** "Borré sólo la relación, no los nodos. Si quisiera
  borrar un nodo completo usaría `DETACH DELETE`, que se lleva el
  nodo y todas sus relaciones de una sola vez."

## 11. Cierre — por qué grafos

- **Decir:**
  - "Relaciones de primera clase: no son llaves foráneas, son el
    centro del modelo."
  - "Cypher es declarativo y visual: la consulta se parece al
    diagrama."
  - "Recorridos profundos (amigos-de-amigos, rutas, detección de
    fraude, recomendaciones) son rápidos y naturales."
  - "Sin esquema rígido: puedo agregar propiedades y tipos de
    relación sin migraciones complicadas."
  - "Casos típicos: redes sociales, recomendaciones, knowledge
    graphs, detección de fraude, sistemas de identidad/acceso."

> Si sobra tiempo: mostrar `cypher/05_graph_traversal_queries.cypher`
> con la consulta de "amigos de amigos de Ana".
