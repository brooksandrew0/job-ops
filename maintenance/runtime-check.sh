#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(git rev-parse --show-toplevel)"
container="jobops-maintenance-check-${RANDOM}"
trap 'docker rm -fv "$container" >/dev/null 2>&1 || true' EXIT
docker run -d --name "$container" --cap-drop ALL --security-opt no-new-privileges:true --pids-limit 512 jobops-maintenance:local >/dev/null
for attempt in $(seq 1 90); do
  if [ "$(docker inspect --format '{{.State.Health.Status}}' "$container")" = healthy ]; then break; fi
  sleep 2
done
test "$(docker inspect --format '{{.State.Health.Status}}' "$container")" = healthy
docker exec -i "$container" python3 < "$repo_dir/maintenance/smoke.py"
docker exec -i "$container" python3 < "$repo_dir/maintenance/browser-smoke.py"
docker exec "$container" python3 -m pip check
docker exec -i "$container" python3 <<'PY'
import json, subprocess
from jwcrypto import jwk, jwt
key = jwk.JWK.generate(kty='oct', size=256)
token = jwt.JWT(header={'alg': 'HS256'}, claims={'probe': True})
token.make_signed_token(key)
assert json.loads(jwt.JWT(key=key, jwt=token.serialize()).claims)['probe']
subprocess.run(['typst', 'compile', '-', '/tmp/validation.pdf'], input=b'Maintenance validation', check=True)
assert open('/tmp/validation.pdf', 'rb').read(5) == b'%PDF-'
print('PASS JWT and PDF generation')
PY
