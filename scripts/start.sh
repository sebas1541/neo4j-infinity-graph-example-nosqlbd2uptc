#!/usr/bin/env bash
# Inicia Neo4j con Docker Compose y espera a que esté listo.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "-> Iniciando Neo4j con Docker Compose..."
docker compose up -d

echo "-> Esperando a que Neo4j acepte consultas..."
TIMEOUT=120
ELAPSED=0
until docker compose exec -T neo4j cypher-shell -u neo4j -p clase2026 "RETURN 1" >/dev/null 2>&1; do
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    echo "ERROR: Timeout esperando a Neo4j (${TIMEOUT}s)." >&2
    echo "       Revisa los logs con: docker compose logs neo4j" >&2
    exit 1
  fi
  sleep 3
  ELAPSED=$((ELAPSED + 3))
  printf '.'
done
echo ""
echo "OK: Neo4j está listo."
echo ""
echo "  Browser: http://localhost:7474"
echo "  Usuario: neo4j"
echo "  Clave:   clase2026"
