#!/usr/bin/env bash
# Borra TODOS los nodos y relaciones del grafo, dejando la base vacía.
# El contenedor sigue corriendo. Para recargar el seed: ./scripts/reset-demo.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -z "$(docker compose ps --status running --quiet neo4j 2>/dev/null)" ]; then
  echo "ERROR: Neo4j no está corriendo. Levántalo con ./scripts/start.sh" >&2
  exit 1
fi

echo "-> Borrando todos los nodos y relaciones..."
./scripts/run-query-file.sh cypher/00_clean.cypher

echo "-> Verificando que el grafo esté vacío..."
docker compose exec -T neo4j cypher-shell -u neo4j -p clase2026 --format plain \
  "MATCH (n) RETURN count(n) AS nodos_restantes;"

echo "OK: Grafo limpio. Para recargar el seed: ./scripts/reset-demo.sh"
