# Cypher — Cheatsheet rápida

Una página con la sintaxis mínima de Cypher, con ejemplos sobre el
dataset de la demo (Ana, Luis, Juan, Sara, Pedro / ACME, Globex).

## Patrones básicos

### Nodo

```
( variable : Etiqueta { propiedad: valor } )
```

Ejemplo:

```cypher
(ana:Persona {nombre: 'Ana'})
```

### Relación

```
-[ variable : TIPO { propiedad: valor } ]->
```

- `-[:TIPO]->` dirigida hacia la derecha
- `<-[:TIPO]-` dirigida hacia la izquierda
- `-[:TIPO]-`  sin dirección (cualquiera)

Ejemplo:

```cypher
(ana)-[:AMIGO_DE {desde: 2019}]->(luis)
```

## CREATE — crear nodos y relaciones

```cypher
CREATE (ana:Persona {nombre: 'Ana', edad: 28});

CREATE
  (a:Persona {nombre: 'A'}),
  (b:Persona {nombre: 'B'}),
  (a)-[:AMIGO_DE {desde: 2024}]->(b);
```

## MATCH — buscar nodos / patrones

```cypher
MATCH (p:Persona) RETURN p;

MATCH (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE]-(amigo)
RETURN amigo.nombre;
```

## WHERE — filtros

```cypher
MATCH (p:Persona)
WHERE p.edad > 28 AND p.ciudad = 'Bogotá'
RETURN p.nombre;
```

## RETURN — proyección, alias, agregaciones

```cypher
MATCH (p:Persona)
RETURN p.nombre AS nombre, p.edad AS edad
ORDER BY edad DESC
LIMIT 3;

MATCH (p:Persona)
RETURN p.ciudad AS ciudad, count(*) AS total;
```

## SET — actualizar propiedades / etiquetas

```cypher
MATCH (ana:Persona {nombre: 'Ana'})
SET ana.profesion = 'Data Engineer', ana.edad = 29;

MATCH (p:Persona {nombre: 'Pedro'})
SET p:Senior;   // agrega la etiqueta :Senior
```

## DELETE — borrar relaciones o nodos sin relaciones

```cypher
MATCH (:Persona {nombre: 'Ana'})-[r:AMIGO_DE]-(:Persona {nombre: 'Sara'})
DELETE r;
```

> `DELETE` sobre un nodo que aún tiene relaciones FALLA.
> Usa `DETACH DELETE` (abajo) para esos casos.

## DETACH DELETE — borrar nodo + todas sus relaciones

```cypher
MATCH (p:Persona {nombre: 'Pedro'}) DETACH DELETE p;

MATCH (n) DETACH DELETE n;   // limpia todo el grafo
```

## MERGE — crear si no existe, encontrar si existe

```cypher
MERGE (bog:Ciudad {nombre: 'Bogotá'});

MATCH (ana:Persona {nombre: 'Ana'})
MERGE (bog:Ciudad {nombre: 'Bogotá'})
MERGE (ana)-[:VIVE_EN]->(bog);
```

`MERGE` es idempotente: se puede correr varias veces sin duplicar.

## shortestPath — camino más corto entre dos nodos

```cypher
MATCH ruta = shortestPath(
  (a:Persona {nombre: 'Ana'})-[:AMIGO_DE*]-(b:Persona {nombre: 'Pedro'})
)
RETURN [n IN nodes(ruta) | n.nombre] AS camino,
       length(ruta) AS saltos;
```

- `[:AMIGO_DE*]`      — cualquier número de saltos
- `[:AMIGO_DE*1..3]`  — entre 1 y 3 saltos
- `allShortestPaths(...)` — todos los caminos más cortos (no sólo uno)

## Otros operadores útiles

| Operador          | Significado                                      |
| ----------------- | ------------------------------------------------ |
| `labels(n)`       | lista de etiquetas del nodo                      |
| `type(r)`         | tipo de la relación                              |
| `count(*)`        | cuenta filas                                     |
| `collect(x)`      | agrega valores en una lista                      |
| `DISTINCT`        | elimina duplicados                               |
| `WITH`            | pasa resultados parciales a la siguiente cláusula |
| `OPTIONAL MATCH`  | como MATCH pero permite ausencia (igual que LEFT JOIN) |
