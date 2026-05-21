#!/usr/bin/env bash
# Limpia el grafo y recarga el dataset de demostración.
set -euo pipefail

cd "$(dirname "$0")/.."

# Asegura que Neo4j esté corriendo
if [ -z "$(docker compose ps --status running --quiet neo4j 2>/dev/null)" ]; then
  echo "-> Neo4j no está corriendo. Iniciándolo primero..."
  ./scripts/start.sh
fi

echo "-> Limpiando grafo..."
./scripts/run-query-file.sh cypher/00_clean.cypher

echo "-> Cargando dataset de demostración..."
./scripts/run-query-file.sh cypher/01_create_demo_graph.cypher

echo "OK: Demo cargado. Abre http://localhost:7474 y ejecuta:  MATCH (n) RETURN n"
