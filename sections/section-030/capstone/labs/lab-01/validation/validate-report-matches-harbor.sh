#!/usr/bin/env bash
# PASS when: confirms /root/inventory-report.json lists every tag in inventory with its digest.
set -uo pipefail
# grep -q stops reading at the first match; under pipefail the command
# writing into the pipe then fails with SIGPIPE and a match looks like a
# failure. This wrapper reads all input instead and keeps grep's exit status.
grep() {
  local arg quiet=0 args=()
  for arg in "$@"; do
    case "$arg" in
      --quiet|--silent) quiet=1 ;;
      --*) args+=("$arg") ;;
      -*q*) quiet=1; [ "$arg" = "-q" ] || args+=("${arg//q/}") ;;
      *) args+=("$arg") ;;
    esac
  done
  if [ "$quiet" = 1 ]; then command grep "${args[@]}" >/dev/null; else command grep "$@"; fi
}

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

# create_project NAME: creates a private project if it does not exist yet.
create_project() {
  local found
  found="$(harbor_api GET "/projects?name=$1" 2>/dev/null || true)"
  if ! printf '%s' "$found" | grep -Eq "\"name\": ?\"$1\""; then
    harbor_api POST /projects "{\"project_name\":\"$1\",\"metadata\":{\"public\":\"false\"}}" >/dev/null
  fi
}

# create_user NAME PASSWORD: creates a Harbor user if it does not exist yet.
create_user() {
  local found
  found="$(harbor_api GET "/users/search?username=$1" 2>/dev/null || true)"
  if ! printf '%s' "$found" | grep -Eq "\"username\": ?\"$1\""; then
    harbor_api POST /users "{\"username\":\"$1\",\"email\":\"$1@example.com\",\"realname\":\"$1\",\"password\":\"$2\",\"comment\":\"lab user\"}" >/dev/null
  fi
}

# add_member PROJECT USER ROLE_ID: 1 Project Admin, 2 Developer, 3 Guest, 4 Maintainer.
add_member() {
  harbor_api POST "/projects/$1/members" "{\"role_id\":$3,\"member_user\":{\"username\":\"$2\"}}" >/dev/null 2>&1 || true
}

# copy_to_harbor SOURCE TARGET: copies an image or chart into Harbor with regctl.
copy_to_harbor() {
  ws regctl registry login "$HARBOR_HOST" -u admin -p Harbor12345 >/dev/null
  ws regctl image copy "$1" "$HARBOR_HOST/$2"
}

# record_baseline KEY VALUE: keeps a value the graders compare against later.
record_baseline() {
  # Create the ConfigMap only once; applying a one-key ConfigMap would erase
  # the values recorded before it.
  kubectl -n harbor get configmap lab-baseline >/dev/null 2>&1 || \
    kubectl -n harbor create configmap lab-baseline >/dev/null
  kubectl -n harbor patch configmap lab-baseline --type merge -p "{\"data\":{\"$1\":\"$2\"}}" >/dev/null
}

helm_revision() { helm -n harbor history harbor -o json | jq -r '.[-1].revision'; }

# unhealthy_components: prints the name of every component the health API
# does not report as healthy (empty output means all healthy).
unhealthy_components() {
  ws sh -c "curl -fsS $HARBOR_URL/api/v2.0/health | jq -r '.components[] | select(.status != \"healthy\") | .name'"
}

# push_check REPOSITORY: pushes a small file as an OCI artifact; exit 0 on success.
push_check() {
  ws sh -c "echo graded > /tmp/check.txt && cd /tmp && oras login $HARBOR_HOST -u admin -p Harbor12345 >/dev/null 2>&1 && oras push $HARBOR_HOST/$1:grader check.txt:text/plain >/dev/null 2>&1"
}

# current_credential FIELD: prints a field (username, serveraddress) of the
# harbor CLI's current credential, read from its configuration file. The CLI
# writes current-credential-name after the credentials list, so the values are
# collected first and printed at the end.
current_credential() {
  ws cat /root/.config/harbor-cli/config.yaml 2>/dev/null | awk -v field="$1" '
    /^current-credential-name:/ { current = $2 }
    /^[[:space:]]*- name:/ { name = $3 }
    $1 == field ":" { value[name] = $2 }
    END { print value[current] }'
}

REPORT="$(ws sh -c 'jq -c "[.[] | {repository, tag, digest}] | sort_by(.repository, .tag)" /root/inventory-report.json' 2>/dev/null)"
if [ -z "$REPORT" ]; then
  echo "FAIL: /root/inventory-report.json is missing or is not a JSON array of objects."
  exit 1
fi
TRUTH="$(ws sh -c '
  for repo in $(curl -fsS -u admin:Harbor12345 "'"$HARBOR_URL"'/api/v2.0/projects/inventory/repositories?page_size=100" | jq -r ".[].name"); do
    name="${repo#inventory/}"; encoded="$(printf %s "$name" | sed "s|/|%252F|g")"
    curl -fsS -u admin:Harbor12345 "'"$HARBOR_URL"'/api/v2.0/projects/inventory/repositories/$encoded/artifacts?page_size=100&with_tag=true" \
      | jq -c --arg repo "$repo" ".[] | .digest as \$d | .tags[]? | {repository: \$repo, tag: .name, digest: \$d}"
  done | jq -s -c "sort_by(.repository, .tag)"')"
if [ "$REPORT" != "$TRUTH" ]; then
  echo "FAIL: the report does not match Harbor."
  echo "  report: $REPORT"
  echo "  Harbor: $TRUTH"
  exit 1
fi
echo "PASS: the report lists every tag in inventory with its digest."
