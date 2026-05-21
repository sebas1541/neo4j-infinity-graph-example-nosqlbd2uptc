#!/usr/bin/env bash
# Ejecuta un archivo .cypher contra el contenedor de Neo4j vía cypher-shell.
#
# Uso:
#   ./scripts/run-query-file.sh cypher/02_read_queries.cypher
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Uso: $0 <archivo.cypher>" >&2
  exit 1
fi

FILE="$1"
cd "$(dirname "$0")/.."

if [ ! -f "$FILE" ]; then
  echo "ERROR: Archivo no encontrado: $FILE" >&2
  exit 1
fi

docker compose exec -T neo4j cypher-shell \
  -u neo4j -p clase2026 \
  --format plain \
  < "$FILE"
