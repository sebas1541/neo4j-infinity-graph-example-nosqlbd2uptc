#!/usr/bin/env bash
# Detiene el contenedor de Neo4j. Los datos se conservan en el volumen.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "-> Deteniendo Neo4j..."
docker compose down
echo "OK: Neo4j detenido (los datos persisten en el volumen 'neo4j_data')."
echo "    Para borrar también los datos: docker compose down -v"
