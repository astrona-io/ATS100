#!/usr/bin/env bash
# Runs before the reference solution: waits until Harbor answers and the
# workstation trusts it. `astrona test` bootstraps and applies in one go.
set -uo pipefail

export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"
HARBOR_URL="https://harbor.localtest.me:8443"
HARBOR_HOST="harbor.localtest.me:8443"

# Runs a command in the workstation pod, where the client tools live.
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }

# harbor_api METHOD PATH [JSON]: calls the Harbor REST API v2.0 as admin
# (lab-only password) from the workstation pod.
harbor_api() {
  local method="$1" path="$2" body="${3:-}"
  if [ -n "$body" ]; then
    printf '%s' "$body" | ws curl -fsS -u admin:Harbor12345 -X "$method" \
      -H 'Content-Type: application/json' --data-binary @- "$HARBOR_URL/api/v2.0$path"
  else
    ws curl -fsS -u admin:Harbor12345 -X "$method" "$HARBOR_URL/api/v2.0$path"
  fi
}

for _ in $(seq 1 180); do
  if ws curl -fsS "$HARBOR_URL/api/v2.0/ping" >/dev/null 2>&1; then
    exit 0
  fi
  sleep 5
done
echo "Harbor did not answer in time." >&2
exit 1
