#!/bin/sh
set -u
cd /app
failed=0
run() { printf '\nCHECK %s\n' "$*"; "$@" || failed=1; }
biome=./orchestrator/node_modules/.bin/biome
[ -x "$biome" ] || biome=./node_modules/.bin/biome
run "$biome" ci .
run npm run check:types:shared
run npm --workspace orchestrator run check:types
run npm --workspace gradcracker-extractor run check:types
run npm --workspace ukvisajobs-extractor run check:types
run npm --workspace orchestrator run build:client
run npm --workspace orchestrator run test:run
exit "$failed"
