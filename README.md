# Neo4j Demo — Mini Red Social

Demo local de **Neo4j 5.26 Community** corriendo en Docker. Es un grafo
de prueba con personas, empresas, amistades y relaciones laborales,
pensado para mostrar en una clase cómo funciona una base de datos de
grafos y cómo se compara con SQL.

Si nunca has tocado Neo4j: este README te lleva paso a paso desde
"clonar el repo" hasta "tener el grafo cargado y probar todas las
consultas". Cada bloque de código se puede copiar y pegar tal cual.

---

## Tabla de contenidos

1. [Requisitos](#1-requisitos)
2. [Quick start (TL;DR)](#2-quick-start-tldr)
3. [Estructura del proyecto](#3-estructura-del-proyecto)
4. [El dataset](#4-el-dataset)
5. [Walkthrough — probar el ejemplo paso a paso](#5-walkthrough--probar-el-ejemplo-paso-a-paso)
6. [Lista de comandos](#6-lista-de-comandos)
7. [Tips para el Neo4j Browser](#7-tips-para-el-neo4j-browser)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Requisitos

| Herramienta       | Versión mínima | Cómo verificar              |
| ----------------- | -------------- | --------------------------- |
| Docker Engine     | 20.x           | `docker --version`          |
| Docker Compose v2 | 2.x            | `docker compose version`    |
| macOS / Linux     | cualquiera     | (los scripts son `bash`)    |

Verifica también que **el daemon de Docker esté corriendo** antes de
empezar:

```bash
docker info >/dev/null && echo "Docker OK" || echo "Inicia Docker Desktop"
```

Puertos que se usan en `localhost`: **`7474`** (Browser) y **`7687`**
(Bolt). Si los tienes ocupados, libéralos o cambia el mapeo en
`docker-compose.yml`.

---

## 2. Quick start (TL;DR)

```bash
cd /Users/sebas1541/Projects/electiva2

# Levanta Neo4j Y carga el dataset (un solo comando)
./scripts/reset-demo.sh

# Abre el Browser
open http://localhost:7474
```

En el login del Browser:

| Campo        | Valor                  |
| ------------ | ---------------------- |
| Connect URL  | `bolt://localhost:7687`|
| Usuario      | `neo4j`                |
| Password     | `clase2026`            |

Pega esta consulta y dale a **Play** (`Ctrl/Cmd + Enter`):

```cypher
MATCH (n) RETURN n;
```

Deberías ver 26 nodos (22 personas + 4 empresas) conectados.

---

## 3. Estructura del proyecto

```
electiva2/
├── docker-compose.yml          # Servicio Neo4j Community 5.26
├── README.md                   # Este archivo
├── presentation_demo_script.md # Guion paso a paso para la expo
├── quick_cheatsheet.md         # Referencia rápida de sintaxis Cypher
├── cypher/
│   ├── 00_clean.cypher                    # Borra todo
│   ├── 01_create_demo_graph.cypher        # Crea el dataset
│   ├── 02_read_queries.cypher             # READ
│   ├── 03_update_queries.cypher           # UPDATE + MERGE
│   ├── 04_delete_queries.cypher           # DELETE
│   └── 05_graph_traversal_queries.cypher  # shortestPath, FoF, etc.
└── scripts/
    ├── start.sh              # Levanta el contenedor
    ├── stop.sh               # Lo detiene (preserva los datos)
    ├── reset-demo.sh         # Limpia + recarga el seed
    ├── clean-demo.sh         # Sólo limpia (deja la base vacía)
    └── run-query-file.sh     # Ejecuta cualquier .cypher en el contenedor
```

---

## 4. El dataset

### Esquema

```
(:Persona  {nombre, edad, ciudad})
(:Empresa  {nombre})

(:Persona)-[:AMIGO_DE   {desde}]->(:Persona)
(:Persona)-[:TRABAJA_EN {rol}  ]->(:Empresa)
```

`AMIGO_DE` se guarda como relación dirigida pero la amistad es
simétrica: en las consultas se usa el patrón sin flecha
(`-[:AMIGO_DE]-`).

### Personas (22)

Distribución por ciudad:

| Ciudad        | Personas                                                |
| ------------- | ------------------------------------------------------- |
| Bogotá (7)    | Ana, Sara, Camila, Andrés, Mariana, Isabella, Andrea    |
| Medellín (5)  | Luis, Diego, Carlos, Sofía, Ricardo                     |
| Cali (3)      | Juan, Valentina, Sebastián                              |
| Barranquilla (2) | Pedro, Paula                                         |
| Cartagena (1) | Laura                                                   |
| Bucaramanga (1)| Felipe                                                 |
| Pereira (1)   | Daniela                                                 |
| Manizales (1) | Mateo                                                   |
| Santa Marta (1)| Nicolás                                                |

### Empresas (4)

| Empresa  | Empleados |
| -------- | --------- |
| ACME     | 6 (Ana, Juan, Camila, Diego, Mariana, Felipe)         |
| Hooli    | 6 (Laura, Paula, Mateo, Ricardo, Daniela, Pedro)      |
| Globex   | 5 (Luis, Sara, Andrés, Sofía, Nicolás)                |
| Initech  | 5 (Valentina, Carlos, Isabella, Sebastián, Andrea)    |

### Relaciones

- **31** amistades (`AMIGO_DE`) organizadas en tres clusters
  (Bogotá, Medellín, Cali) más puentes entre ciudades.
- **22** contratos (`TRABAJA_EN`) — cada persona trabaja en una sola
  empresa.

### Las 5 personas "originales"

Ana, Luis, Juan, Sara y Pedro son las personas que aparecen en el
guion de la presentación. Sus datos no han cambiado y sus relaciones
clave (Ana–Sara, Sara–Pedro, etc.) siguen igual, así que todas las
consultas del guion funcionan.

---

## 5. Walkthrough — probar el ejemplo paso a paso

Esta sección te lleva por cada operación (CRUD + traversal) con la
consulta a pegar y el resultado esperado. Hazlo en el Browser
(<http://localhost:7474>) o en terminal con
`./scripts/run-query-file.sh`.

### 5.1 Levantar Neo4j y cargar datos

```bash
./scripts/reset-demo.sh
```

**Salida esperada (resumida):**

```
-> Limpiando grafo...
-> Cargando dataset de demostración...
OK: Demo cargado. Abre http://localhost:7474 y ejecuta:  MATCH (n) RETURN n
```

### 5.2 Verificar que cargó bien

```bash
docker compose exec neo4j cypher-shell -u neo4j -p clase2026 \
  "MATCH (n) RETURN labels(n)[0] AS tipo, count(*) AS total ORDER BY tipo;"
```

**Resultado esperado:**

```
tipo     | total
---------+------
Empresa  | 4
Persona  | 22
```

### 5.3 READ — leer datos

#### a) Mostrar todo el grafo (en el Browser)

```cypher
MATCH (n) RETURN n;
```

En el Browser ves 26 nodos conectados. Cambia a la pestaña **Table**
si quieres verlos como filas.

#### b) Amigos de Ana

```cypher
MATCH (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE]-(amigo:Persona)
RETURN amigo.nombre AS amigo, amigo.ciudad AS ciudad
ORDER BY amigo;
```

**Resultado esperado:** 5 filas — Andrea, Camila, Luis, Mariana, Sara.

#### c) Personas agrupadas por ciudad

```cypher
MATCH (p:Persona)
RETURN p.ciudad AS ciudad, collect(p.nombre) AS personas, count(*) AS total
ORDER BY total DESC, ciudad;
```

**Resultado esperado:** 9 ciudades, Bogotá con 7 personas a la cabeza.

#### d) Trabajadores por empresa

```cypher
MATCH (p:Persona)-[t:TRABAJA_EN]->(e:Empresa)
RETURN e.nombre AS empresa,
       collect({nombre: p.nombre, rol: t.rol}) AS empleados;
```

**Resultado esperado:** 4 empresas, cada una con una lista de
empleados con su rol.

#### e) Correr el archivo completo

```bash
./scripts/run-query-file.sh cypher/02_read_queries.cypher
```

### 5.4 UPDATE — actualizar y MERGE

```cypher
// Cambia la profesión y edad de Ana
MATCH (ana:Persona {nombre: 'Ana'})
SET ana.profesion = 'Data Engineer Senior',
    ana.edad      = 29
RETURN ana.nombre, ana.edad, ana.profesion;
```

```cypher
// MERGE: crea las ciudades como nodos y conéctalas con VIVE_EN
MATCH (p:Persona)
MERGE (c:Ciudad {nombre: p.ciudad})
MERGE (p)-[:VIVE_EN]->(c)
RETURN p.nombre AS persona, c.nombre AS ciudad
ORDER BY ciudad, persona;
```

**Después de esto** el grafo tiene 9 nodos nuevos `:Ciudad` y 22
relaciones `VIVE_EN`. Vuelve a correr `MATCH (n) RETURN n` y verás
una nueva capa morada (si aplicaste el estilo del Browser).

O todo el archivo:

```bash
./scripts/run-query-file.sh cypher/03_update_queries.cypher
```

### 5.5 DELETE — borrar

```cypher
// Borra UNA relación: la amistad Ana - Sara
MATCH (:Persona {nombre: 'Ana'})-[r:AMIGO_DE]-(:Persona {nombre: 'Sara'})
DELETE r;
```

**Verificación:**

```cypher
MATCH (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE]-(amigo:Persona)
RETURN amigo.nombre
ORDER BY amigo.nombre;
```

Ahora Ana tiene **4 amigos** (Sara desapareció).

> Nota: si después corres `shortestPath` Ana → Pedro, el camino cambia
> a **3 saltos** (Ana → Luis → Juan → Pedro) porque el atajo por Sara
> ya no existe. Es buenísimo para mostrar en la expo.

### 5.6 TRAVERSAL — recorridos de grafo

#### a) Camino más corto Ana → Pedro

```cypher
MATCH ruta = shortestPath(
  (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE*]-(pedro:Persona {nombre: 'Pedro'})
)
RETURN [n IN nodes(ruta) | n.nombre] AS camino, length(ruta) AS saltos;
```

**Resultado esperado (con dataset fresco):** `["Ana", "Sara", "Pedro"]`,
2 saltos.

#### b) Amigos de los amigos de Ana

```cypher
MATCH (ana:Persona {nombre: 'Ana'})-[:AMIGO_DE]-(amigo:Persona)-[:AMIGO_DE]-(fof:Persona)
WHERE fof <> ana AND NOT (ana)-[:AMIGO_DE]-(fof)
RETURN DISTINCT fof.nombre AS amigo_de_amigo,
                fof.ciudad AS ciudad
ORDER BY amigo_de_amigo;
```

**Resultado esperado:** ~7 personas (Andrés, Daniela, Diego, Isabella,
Juan, Pedro, Sofía). Es la base de un sistema de recomendaciones tipo
"personas que quizás conoces".

#### c) Compañeros de trabajo de Juan

```cypher
MATCH (juan:Persona {nombre: 'Juan'})-[:TRABAJA_EN]->(e:Empresa)<-[:TRABAJA_EN]-(colega:Persona)
WHERE colega <> juan
RETURN colega.nombre AS companero, e.nombre AS empresa;
```

**Resultado esperado:** 5 compañeros (Ana, Camila, Diego, Mariana,
Felipe) — todos en ACME.

### 5.7 Volver a empezar

```bash
./scripts/reset-demo.sh
```

Limpia el grafo y vuelve a cargar el seed. Útil después de hacer
muchos cambios para "resetear" la demo.

---

## 6. Lista de comandos

### Scripts del proyecto

| Comando                                            | Qué hace                                    |
| -------------------------------------------------- | ------------------------------------------- |
| `./scripts/start.sh`                               | Levanta Neo4j y espera healthcheck         |
| `./scripts/stop.sh`                                | Detiene Neo4j (preserva datos)             |
| `./scripts/reset-demo.sh`                          | Limpia + recarga el seed                   |
| `./scripts/clean-demo.sh`                          | Sólo limpia el grafo (lo deja vacío)       |
| `./scripts/run-query-file.sh cypher/02_read_queries.cypher` | Ejecuta cualquier archivo `.cypher`        |

### Docker

| Comando                            | Qué hace                                        |
| ---------------------------------- | ----------------------------------------------- |
| `docker compose ps`                | Estado del contenedor                          |
| `docker compose logs -f neo4j`     | Logs en vivo                                   |
| `docker compose down`              | Detiene (preserva volumen)                     |
| `docker compose down -v`           | Detiene y **borra el volumen** (reset total)   |
| `docker compose exec neo4j bash`   | Shell dentro del contenedor                    |

### Consulta ad-hoc desde terminal

```bash
docker compose exec neo4j cypher-shell -u neo4j -p clase2026 \
  "MATCH (p:Persona) RETURN p.nombre ORDER BY p.nombre;"
```

---

## 7. Tips para el Neo4j Browser

### Mostrar nombres en lugar de ciudades en los nodos

Por defecto el Browser puede elegir cualquier propiedad para mostrar
en cada nodo. Para fijar `nombre`:

1. Abajo del panel del grafo aparecen chips con las etiquetas
   (`Persona`, `Empresa`, ...).
2. Click en el chip de `Persona` → se abre un panelito.
3. En **Caption** elige `<nombre>`.
4. Repite para `Empresa`.

### Estilo persistente con `:style`

Pega esto en el editor del Browser para aplicar colores y captions de
una vez:

```css
node.Persona  { caption: '{nombre}'; color: #A5D6A7; border-color: #2e7d32; diameter: 65px; }
node.Empresa  { caption: '{nombre}'; color: #FFB74D; border-color: #e65100; diameter: 75px; }
node.Ciudad   { caption: '{nombre}'; color: #CE93D8; border-color: #6a1b9a; }
relationship.AMIGO_DE   { color: #66BB6A; shaft-width: 2px; }
relationship.TRABAJA_EN { color: #FFA726; shaft-width: 2px; }
```

Luego apretas **Apply**.

### Atajos útiles

| Atajo                 | Acción                                  |
| --------------------- | --------------------------------------- |
| `Ctrl/Cmd + Enter`    | Ejecutar la consulta                    |
| Click en un nodo      | Ver propiedades en el panel inferior    |
| Doble click           | Expandir vecinos (sin escribir Cypher)  |
| Arrastrar             | Reacomodar nodos para que se vean       |
| Tecla `Esc`           | Cerrar resultado actual                 |

---

## 8. Troubleshooting

### El Browser no carga en `http://localhost:7474`

```bash
docker compose ps                   # estado debe ser "running, healthy"
docker compose logs --tail=50 neo4j # mira el log
lsof -i :7474                       # ¿otro proceso ocupa el puerto?
```

### Login falla con "ServiceUnavailable" o "Connection refused"

Neo4j tarda ~30 segundos en aceptar conexiones en el primer arranque.
`./scripts/start.sh` espera al healthcheck automáticamente. Si
arrancaste el contenedor con `docker compose up -d` directamente,
dale unos segundos y reintenta.

### Login falla con "Unauthorized"

La password es **`clase2026`**. Si la cambiaste sin querer dentro de
Neo4j Browser, hazle un reset total:

```bash
docker compose down -v   # borra el volumen
./scripts/reset-demo.sh  # crea de cero
```

### Quiero borrar todo y empezar desde cero

```bash
docker compose down -v   # borra contenedor + volumen
./scripts/reset-demo.sh  # arranca y vuelve a sembrar
```

### El daemon de Docker no responde

`docker info` falla. Abre **Docker Desktop** (macOS / Windows) o
arranca el servicio (`sudo systemctl start docker` en Linux) y
vuelve a intentar.

### Cambié el seed y quiero ver mis cambios

```bash
./scripts/reset-demo.sh
```

Re-ejecuta `cypher/00_clean.cypher` + `cypher/01_create_demo_graph.cypher`
contra la base ya en marcha.
