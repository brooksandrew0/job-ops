#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(git rev-parse --show-toplevel)"
context_dir="${1:?Provide a new absolute build-context directory}"
case "$context_dir" in /*) ;; *) echo 'Use an absolute path' >&2; exit 1;; esac
test ! -e "$context_dir"
mkdir -p "$context_dir/source"
git -C "$repo_dir" archive HEAD | tar -x -C "$context_dir/source"
cp "$repo_dir/maintenance/Dockerfile.security" "$repo_dir/maintenance/.dockerignore" "$context_dir/"
docker build --target build -f "$context_dir/Dockerfile.security" -t jobops-maintenance-build:local "$context_dir"
docker run --rm --entrypoint sh -v "$repo_dir/maintenance/validate.sh:/validate.sh:ro" jobops-maintenance-build:local /validate.sh
docker build --build-arg "MAINTENANCE_REVISION=$(git -C "$repo_dir" rev-parse HEAD)" --target production -f "$context_dir/Dockerfile.security" -t jobops-maintenance:local "$context_dir"
