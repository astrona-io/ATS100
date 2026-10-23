#!/usr/bin/env bash
# Creates the starting state for ats-100-capstone-020.
#
# The fixed state is NOT created here — producing it is the task.
set -euo pipefail
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

echo "[lab] Creating the project inventory..."
create_project inventory

echo "[lab] Creating the lab certificate authority and a certificate for the wrong host name..."
ws sh -c 'apk add --no-cache openssl >/dev/null && mkdir -p /tmp/pki && cd /tmp/pki &&
  openssl req -x509 -newkey rsa:2048 -nodes -days 365 -subj "/CN=Inventory Lab CA" -keyout ca.key -out ca.crt 2>/dev/null &&
  openssl req -newkey rsa:2048 -nodes -subj "/CN=harbor.example.com" -addext "subjectAltName=DNS:harbor.example.com" -keyout tls.key -out tls.csr 2>/dev/null &&
  printf "subjectAltName=DNS:harbor.example.com\n" > san.ext &&
  openssl x509 -req -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 90 -extfile san.ext -out tls.crt 2>/dev/null'
WORK="$(mktemp -d)"
for file in ca.crt ca.key tls.crt tls.key; do
  ws cat "/tmp/pki/$file" > "$WORK/$file"
done
kubectl -n harbor create secret generic lab-ca --from-file=ca.crt="$WORK/ca.crt" --from-file=ca.key="$WORK/ca.key" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n harbor create secret generic harbor-tls --from-file=tls.crt="$WORK/tls.crt" \
  --from-file=tls.key="$WORK/tls.key" --from-file=ca.crt="$WORK/ca.crt" \
  --dry-run=client -o yaml | kubectl apply -f -
rm -rf "$WORK"
ws rm -rf /tmp/pki

echo "[lab] Switching Harbor to the certificate from the Secret harbor-tls..."
helm upgrade harbor harbor/harbor --version 1.19.4 --namespace harbor --reuse-values \
  --set expose.tls.certSource=secret --set expose.tls.secret.secretName=harbor-tls \
  --set caSecretName=harbor-tls --wait --timeout 15m
kubectl -n harbor rollout restart deployment/harbor-nginx deployment/harbor-core
kubectl -n harbor rollout status deployment/harbor-nginx --timeout=300s
echo "[lab] Starting state ready. HTTPS requests from the workstation fail. Diagnosing that is the task."
