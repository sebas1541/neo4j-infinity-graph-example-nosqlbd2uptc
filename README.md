# Neo4j Demo — Mini Red Social

Demo local de **Neo4j 5.26 Community** corriendo en Docker. Es un grafo
de prueba con personas, empresas, amistades y relaciones laborales,
pensado para mostrar en una clase cómo funciona una base de datos de
grafos y cómo se compara con SQL.

Si nunca has tocado Neo4j: este README te lleva paso a paso desde
"clonar el repo" hasta "tener el grafo cargado y probar todas las
consultas". Cada bloque de código se puede copiar y pegar tal cual.

> ### ¿Estás en Windows?
>
> **Lee primero la [sección 2 — Windows con WSL 2](#2-windows-con-wsl-2-recomendado).**
> Los scripts son `bash` y **NO** funcionan en PowerShell, CMD ni Git Bash.
> La forma oficial y soportada es **WSL 2 + Ubuntu + Docker Desktop**.

> ### ¿Por qué Neo4j "normal" y no Infinigraph?
>
> Esta demo usa **Neo4j Community Edition** corriendo en local con
> Docker — **gratis, sin arrendar máquina ni servicio cloud**. No
> levantamos AuraDB ni un clúster Enterprise porque para 22 personas y
> 4 empresas es overkill total.
>
> Si tienes curiosidad por **Neo4j Infinigraph** (la arquitectura
> distribuida que Neo4j lanzó en septiembre de 2025 para grafos de
> 100 TB+), mira el [Apéndice — Usar Neo4j Infinigraph](#10-apéndice--usar-neo4j-infinigraph-opcional).
> Es esencialmente lo mismo, sólo que **distribuido en clúster** en vez
> de un solo nodo. **El Cypher es idéntico**, así que esta demo se
> traduce 1:1 si algún día quieres saltar a producción a escala
> empresarial.

---

## Tabla de contenidos

1. [Requisitos](#1-requisitos)
2. [Windows con WSL 2 (recomendado)](#2-windows-con-wsl-2-recomendado)
3. [Quick start (TL;DR)](#3-quick-start-tldr)
4. [Estructura del proyecto](#4-estructura-del-proyecto)
5. [El dataset](#5-el-dataset)
6. [Walkthrough — probar el ejemplo paso a paso](#6-walkthrough--probar-el-ejemplo-paso-a-paso)
7. [Lista de comandos](#7-lista-de-comandos)
8. [Tips para el Neo4j Browser](#8-tips-para-el-neo4j-browser)
9. [Troubleshooting](#9-troubleshooting)
10. [Apéndice — Usar Neo4j Infinigraph (opcional)](#10-apéndice--usar-neo4j-infinigraph-opcional)

---

## 1. Requisitos

| Herramienta       | Versión mínima  | Cómo verificar / notas                            |
| ----------------- | --------------- | ------------------------------------------------- |
| Docker Engine     | 20.x            | `docker --version`                                |
| Docker Compose v2 | 2.x             | `docker compose version`                          |
| macOS / Linux     | cualquiera      | Los scripts son `bash` y corren directo           |
| **Windows**       | **WSL 2 + Ubuntu** | **Ver [sección 2](#2-windows-con-wsl-2-recomendado)** |

Verifica también que **el daemon de Docker esté corriendo** antes de
empezar:

```bash
docker info >/dev/null && echo "Docker OK" || echo "Inicia Docker Desktop"
```

Puertos que se usan en `localhost`: **`7474`** (Browser) y **`7687`**
(Bolt). Si los tienes ocupados, libéralos o cambia el mapeo en
`docker-compose.yml`.

---

## 2. Windows con WSL 2 (recomendado)

Si estás en Windows, **no intentes correr esto con PowerShell, CMD ni
Git Bash**. Los scripts del proyecto son `bash` puro y dependen de
rutas tipo Unix, ejecución directa de binarios, etc.

La forma oficial es **WSL 2 + Ubuntu + Docker Desktop con backend WSL
2**. Buena noticia: Docker Desktop en Windows **ya usa WSL 2
internamente**, así que esto no es un workaround, es el camino
soportado por Docker.

### Paso 1 — Instalar WSL 2

Abre **PowerShell como Administrador** (click derecho en el menú de
inicio → "Ejecutar como administrador") y ejecuta:

```powershell
wsl --install
```

Esto:

- Habilita la característica WSL en Windows
- Instala el kernel de WSL 2
- Instala **Ubuntu** por defecto

**Reinicia el PC** cuando termine.

Si ya tenías WSL 1 instalado:

```powershell
wsl --set-default-version 2
wsl --install -d Ubuntu
```

### Paso 2 — Configurar Ubuntu

Después de reiniciar, Ubuntu se abre solo. Te pide crear:

- **Usuario** (puede ser cualquier cosa, ej. `sebastian`)
- **Password** — NO es la de Windows, es nueva, sirve para `sudo`
  dentro de Ubuntu

Dentro de la terminal de Ubuntu, actualiza paquetes e instala lo
mínimo:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl
```

### Paso 3 — Instalar Docker Desktop con backend WSL 2

1. Descarga **Docker Desktop**: <https://www.docker.com/products/docker-desktop/>
2. Durante la instalación, **marca "Use WSL 2 instead of Hyper-V"**.
3. Termina la instalación y abre Docker Desktop.
4. Espera a que la ballenita (taskbar) se ponga **verde**.
5. Ve a **Settings → Resources → WSL Integration**.
6. Activa el toggle de tu distro **Ubuntu**.
7. Click en **Apply & Restart**.

Verifica desde la terminal de Ubuntu (no de PowerShell):

```bash
docker --version          # Debe imprimir Docker version 2x.x.x
docker compose version    # Docker Compose version v2.x.x
docker info               # NO debe dar "Cannot connect to the Docker daemon"
```

Si `docker info` falla → abre Docker Desktop en Windows y espera a
que la ballenita esté verde, luego reintenta.

### Paso 4 — Clonar el repo DENTRO de WSL

> **MUY importante:** clona en el filesystem de WSL (`~/`),
> **NO** en `/mnt/c/...`. La diferencia de rendimiento de disco con
> Docker es enorme (10–50x más rápido). Los scripts tampoco funcionan
> bien en `/mnt/c/` por permisos.

```bash
cd ~
git clone https://github.com/sebas1541/neo4j-infinity-graph-example-nosqlbd2uptc.git
cd neo4j-infinity-graph-example-nosqlbd2uptc
```

### Paso 5 — Levantar todo

```bash
./scripts/reset-demo.sh
```

La primera vez descarga la imagen de Neo4j (~500 MB), puede tardar
1–3 minutos. Las siguientes ejecuciones son instantáneas.

Abre <http://localhost:7474> en **tu navegador normal de Windows**
(Chrome, Edge, Firefox — el que sea). WSL 2 reenvía `localhost` al
host de Windows automáticamente, no hay que configurar puertos.

**Login:** usuario `neo4j`, password `clase2026`.

### Tips útiles para WSL 2

| Truco                                | Comando                                           |
| ------------------------------------ | ------------------------------------------------- |
| Abrir el folder en Windows Explorer  | `explorer.exe .` (dentro de WSL)                  |
| Abrir el proyecto en VS Code         | `code .` (necesita la extensión "WSL" en VS Code) |
| Ver la home de WSL desde Windows     | En Explorer: `\\wsl$\Ubuntu\home\<tu_usuario>`    |
| Apagar WSL (libera RAM)              | `wsl --shutdown` (en PowerShell)                  |
| Reiniciar Docker                     | Click derecho en la ballenita → Restart           |
| Ver distros instaladas               | `wsl --list --verbose` (en PowerShell)            |
| Volver a entrar a Ubuntu             | Menú Inicio → "Ubuntu", o `wsl` en PowerShell     |

### Problemas comunes en Windows/WSL

| Problema                                              | Solución                                                                 |
| ----------------------------------------------------- | ------------------------------------------------------------------------ |
| `./scripts/start.sh: not found` o `bad interpreter`   | Clonaste en `/mnt/c/`. Borra y vuelve a clonar en `~/`.                  |
| Scripts con line endings `\r\n`                       | El repo ya trae `.gitattributes` con `eol=lf`. Si igual falla: `git config --global core.autocrlf input` y vuelve a clonar. |
| `docker: command not found` en WSL                    | Activa WSL Integration en Docker Desktop → Settings → Resources.         |
| Todo va lentísimo                                     | Estás corriendo desde `/mnt/c/`. Mueve el proyecto a `~/`.               |
| `http://localhost:7474` no carga desde Windows         | Espera 30s, luego `docker compose ps`. El estado debe ser `healthy`.    |
| WSL no arranca o da error de kernel                    | En PowerShell admin: `wsl --update`, luego `wsl --shutdown`, vuelve a abrir. |
| Docker Desktop dice "Engine stopped"                   | Reinicia Docker Desktop. Si persiste: Settings → Troubleshoot → Reset.  |
| Falla `sudo apt update` con "No connection"            | Reinicia WSL: `wsl --shutdown` en PowerShell, vuelve a abrir Ubuntu.    |

> Después de este setup, **todos los pasos de las secciones 3–9 de
> este README aplican igual**, simplemente los ejecutas dentro de la
> terminal de Ubuntu (no de PowerShell).

---

## 3. Quick start (TL;DR)

```bash
# Clonar (si aún no lo hiciste)
git clone https://github.com/sebas1541/neo4j-infinity-graph-example-nosqlbd2uptc.git
cd neo4j-infinity-graph-example-nosqlbd2uptc

# Levanta Neo4j Y carga el dataset (un solo comando)
./scripts/reset-demo.sh

# Abre el Browser
open http://localhost:7474        # macOS
# xdg-open http://localhost:7474  # Linux
# (Windows/WSL: abre el navegador de Windows manualmente)
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

## 4. Estructura del proyecto

```
electiva2/
├── docker-compose.yml          # Servicio Neo4j Community 5.26
├── .gitattributes              # Fuerza line endings LF (Windows-safe)
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
    ├── stop.sh               # Lo detiene (preserva datos)
    ├── reset-demo.sh         # Limpia + recarga el seed
    ├── clean-demo.sh         # Sólo limpia el grafo (lo deja vacío)
    └── run-query-file.sh     # Ejecuta cualquier .cypher en el contenedor
```

---

## 5. El dataset

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

| Ciudad           | Personas                                                |
| ---------------- | ------------------------------------------------------- |
| Bogotá (7)       | Ana, Sara, Camila, Andrés, Mariana, Isabella, Andrea    |
| Medellín (5)     | Luis, Diego, Carlos, Sofía, Ricardo                     |
| Cali (3)         | Juan, Valentina, Sebastián                              |
| Barranquilla (2) | Pedro, Paula                                            |
| Cartagena (1)    | Laura                                                   |
| Bucaramanga (1)  | Felipe                                                  |
| Pereira (1)      | Daniela                                                 |
| Manizales (1)    | Mateo                                                   |
| Santa Marta (1)  | Nicolás                                                 |

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

## 6. Walkthrough — probar el ejemplo paso a paso

Esta sección te lleva por cada operación (CRUD + traversal) con la
consulta a pegar y el resultado esperado. Hazlo en el Browser
(<http://localhost:7474>) o en terminal con
`./scripts/run-query-file.sh`.

### 6.1 Levantar Neo4j y cargar datos

```bash
./scripts/reset-demo.sh
```

**Salida esperada (resumida):**

```
-> Limpiando grafo...
-> Cargando dataset de demostración...
OK: Demo cargado. Abre http://localhost:7474 y ejecuta:  MATCH (n) RETURN n
```

### 6.2 Verificar que cargó bien

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

### 6.3 READ — leer datos

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

### 6.4 UPDATE — actualizar y MERGE

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

### 6.5 DELETE — borrar

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

### 6.6 TRAVERSAL — recorridos de grafo

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

### 6.7 Volver a empezar

```bash
./scripts/reset-demo.sh
```

Limpia el grafo y vuelve a cargar el seed. Útil después de hacer
muchos cambios para "resetear" la demo.

---

## 7. Lista de comandos

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

## 8. Tips para el Neo4j Browser

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

## 9. Troubleshooting

> Si estás en Windows, mira primero los problemas específicos en la
> [sección 2 — Problemas comunes en Windows/WSL](#problemas-comunes-en-windowswsl).

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

---

## 10. Apéndice — Usar Neo4j Infinigraph (opcional)

**Neo4j Infinigraph** es la nueva arquitectura distribuida que Neo4j
anunció en **septiembre de 2025** y que ya está en GA. Está pensada
para grafos de **100 TB+**, fusiona cargas operacionales (OLTP) y
analíticas (OLAP) en un mismo sistema, y es la base que Neo4j está
empujando para **GraphRAG y agentes con IA** a gran escala.

Para esta demo de clase **no aporta nada nuevo en cuanto a sintaxis**:
el lenguaje sigue siendo Cypher, los mismos `MATCH`, `CREATE`,
`MERGE`, `shortestPath` funcionan igual. Lo único que cambia es que
Infinigraph **distribuye el grafo entre varios nodos** de un clúster
en vez de tenerlo en una sola máquina. Para 22 personas y 4 empresas,
Community Edition local es más que suficiente.

> Resumen: Neo4j Community (lo que usa este repo) e Infinigraph son
> **esencialmente lo mismo**, sólo que Infinigraph es la versión "a
> escala", distribuida y multi-nodo. Si aprendes Cypher acá, ya sabes
> Cypher para Infinigraph.

### Si quieres probar Infinigraph "en serio"

Hay dos caminos. Ninguno es gratis para uso real.

#### Opción A — Neo4j AuraDB (cloud, lo más fácil)

AuraDB es la nube oficial de Neo4j. El soporte de Infinigraph en Aura
está en rollout (al momento de escribir esto, **mayo de 2026**, depende
del plan y la región).

1. Crea cuenta en <https://console.neo4j.io>.
2. **Create Instance** → elige un plan que soporte Infinigraph
   (Aura Professional o Enterprise — las tiers gratis **no** lo
   incluyen).
3. Cuando esté lista te dan:
   - URL Bolt: `neo4j+s://xxxxxxx.databases.neo4j.io`
   - Usuario: `neo4j`
   - Password generada — **descárgala como `.txt`**, sólo se muestra
     una vez.
4. Conecta desde tu terminal con el mismo `cypher-shell`:

   ```bash
   cypher-shell -a "neo4j+s://xxxxxxx.databases.neo4j.io" \
                -u neo4j -p "<tu_password>"
   ```

5. Carga el mismo seed de este repo:

   ```bash
   cypher-shell -a "<URL>" -u neo4j -p "<password>" < cypher/00_clean.cypher
   cypher-shell -a "<URL>" -u neo4j -p "<password>" < cypher/01_create_demo_graph.cypher
   ```

6. Para abrir el Browser web: <https://console.neo4j.io> → tu instancia
   → **Open with Workspace**.

**Costo:** los planes con Infinigraph parten desde ~USD 65/mes. Para
una clase es overkill, pero está bien si quieres ver el dashboard
cloud, métricas, backups automáticos, etc.

#### Opción B — Neo4j Enterprise Edition self-managed (Docker)

Neo4j publica `neo4j:5-enterprise`. Pero Infinigraph **brilla con
clúster**, no con un sólo contenedor.

Lo mínimo para un PoC:

- Aceptar la licencia Enterprise (**gratis para desarrollo**, de pago
  para producción): <https://neo4j.com/licensing/>
- Levantar **3+ contenedores Neo4j** en modo cluster con property
  sharding habilitado.
- Variables de entorno tipo:

  ```yaml
  NEO4J_ACCEPT_LICENSE_AGREEMENT: "yes"
  NEO4J_dbms_mode: "CORE"
  NEO4J_causal__clustering_minimum__core__cluster__size__at__formation: "3"
  NEO4J_causal__clustering_initial__discovery__members: "neo4j1:5000,neo4j2:5000,neo4j3:5000"
  # Property sharding (parte de Infinigraph)
  NEO4J_dbms_cluster_property__sharding_enabled: "true"
  ```

- Documentación oficial:
  - [Neo4j Operations Manual — Clustering](https://neo4j.com/docs/operations-manual/current/clustering/)
  - [Anuncio oficial de Infinigraph (Neo4j Blog)](https://neo4j.com/blog/graph-database/infinigraph-scalable-architecture/)

Es **bastante más laborioso** que este `docker-compose.yml` de un solo
servicio. No tiene sentido para una clase, pero queda como referencia
si en el futuro montas una prueba de concepto a escala real.

### TL;DR — qué usar cuándo

| Opción | Costo | Setup | Recomendado para |
| ------ | ----- | ----- | ---------------- |
| **Community local (este repo)** | $0 | 1 comando | Esta clase, prototipos, aprender Cypher |
| **AuraDB Free Tier** | $0 | Web UI | Probar el cloud (sin Infinigraph) |
| **AuraDB Professional + Infinigraph** | ~$65+/mes | Web UI | Demos cloud con Infinigraph |
| **Enterprise self-managed + cluster** | $0 dev / $$$ prod | Multi-contenedor + config | Equipos con infra propia y > 1 TB de grafo |

**Lo importante:** el código Cypher que está en `cypher/*.cypher`
**funciona idéntico en las cuatro opciones**. Migrar de Community a
Infinigraph no requiere cambiar las consultas, sólo el motor de abajo.

### Lecturas adicionales (en inglés)

- [Neo4j Launches Infinigraph — PR Newswire (sept. 2025)](https://www.prnewswire.com/news-releases/neo4j-launches-infinigraph-the-most-scalable-graph-database-for-unified-operational-and-analytical-workloads-at-100tb-scale-302545785.html)
- [Infinigraph: A Bold Play for Agentic AI — Futurum Group](https://futurumgroup.com/insights/neo4j-infinigraph-makes-a-bold-play-for-the-future-of-ai/)
- [Infinigraph Is GA — Neo4j Online Community](https://community.neo4j.com/t/infinigraph-is-ga-neo4j-s-answer-to-graphs-at-real-scale/76415)
- [Neo4j unveils Infinigraph — InfoWorld](https://www.infoworld.com/article/4051374/neo4j-unveils-infinigraph-to-merge-oltp-and-olap-for-agentic-ai.html)
- [Neo4j Aura Documentation](https://neo4j.com/docs/aura/)
