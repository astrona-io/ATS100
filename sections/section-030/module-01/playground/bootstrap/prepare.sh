#!/usr/bin/env bash
# OS prep for the "Work With Harbor From The Command Line" playground (`ats-100-playground-030-01`).
#
# Environment preparation only. There is no task and no grading. This script:
#   1. puts Helm (pinned) on the PATH,
#   2. makes harbor.localtest.me resolve to the Harbor Service inside the cluster,
#   3. creates the lab CA and Harbor's certificate in the Secret harbor-tls (once),
#      then installs Harbor 2.15.4 with the harbor-helm chart 1.19.4,
#   4. starts the workstation pod with the client tools and Harbor's CA trusted.
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

HELM_VERSION="3.22.1"
HARBOR_CHART_VERSION="1.19.4"
HARBOR_HOST="harbor.localtest.me"

BIN_DIR="/usr/local/bin"
[ -w "$BIN_DIR" ] || BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# Pin Helm rather than accepting whatever is on the machine: the Harbor
# documentation is written for Helm 3.
have_version=""
command -v helm >/dev/null 2>&1 && \
  have_version=$(helm version --template '{{.Version}}' 2>/dev/null | sed 's/^v//')
if [ "$have_version" != "$HELM_VERSION" ]; then
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"
  case "$ARCH" in x86_64) ARCH=amd64 ;; aarch64|arm64) ARCH=arm64 ;; esac
  WORK="$(mktemp -d)"
  trap 'rm -rf "$WORK"' EXIT
  echo "[playground] Downloading Helm ${HELM_VERSION} (${OS}/${ARCH})..."
  curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-${OS}-${ARCH}.tar.gz" | tar -xz -C "$WORK"
  install -m 0755 "$WORK/${OS}-${ARCH}/helm" "$BIN_DIR/helm"
fi
helm version --short

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_DIR=""
for candidate in "$SCRIPT_DIR/../manifests" "./manifests" "$SCRIPT_DIR/manifests"; do
  [ -d "$candidate" ] && { MANIFEST_DIR="$candidate"; break; }
done

# One address for the reader's machine and the cluster: harbor.localtest.me
# resolves to 127.0.0.1 on the machine (reached through a port-forward), and
# this CoreDNS block sends the same name to the Harbor Service in the cluster.
# The answer is rewritten back to the asked name: Go programs ignore DNS
# answers whose name differs from the question.
if ! kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' | grep -q "$HARBOR_HOST"; then
  echo "[playground] Adding the CoreDNS rewrite for ${HARBOR_HOST}..."
  COREFILE="$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' \
    | awk '/^[[:space:]]*kubernetes / && !done {
        print "    rewrite stop {"
        print "        name regex harbor\\.localtest\\.me harbor.harbor.svc.cluster.local"
        print "        answer name harbor\\.harbor\\.svc\\.cluster\\.local harbor.localtest.me"
        print "    }"
        done=1
      } {print}')"
  kubectl -n kube-system create configmap coredns --from-literal=Corefile="$COREFILE" \
    --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n kube-system rollout restart deployment/coredns
  kubectl -n kube-system rollout status deployment/coredns --timeout=120s
fi

# Harbor's TLS certificate comes from the Secret harbor-tls, signed by a lab
# certificate authority (CA) created once here. With certSource auto, the chart
# generates a new CA and certificate on every helm upgrade, and the workstation,
# which trusts the CA it downloaded at start, then refuses every HTTPS request.
# The keys are tls.crt, tls.key and ca.crt; caSecretName in the values makes
# core offer ca.crt at /api/v2.0/systeminfo/getcert.
kubectl create namespace harbor --dry-run=client -o yaml | kubectl apply -f -
if ! kubectl -n harbor get secret harbor-tls >/dev/null 2>&1; then
  echo "[playground] Creating the lab certificate authority and Harbor's certificate..."
  TLS_WORK="$(mktemp -d)"
  cat > "$TLS_WORK/ca.cnf" <<'CNF'
[req]
distinguished_name = dn
[dn]
[v3_ca]
basicConstraints = critical,CA:TRUE
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
CNF
  printf 'subjectAltName=DNS:%s\nextendedKeyUsage=serverAuth\n' "$HARBOR_HOST" > "$TLS_WORK/server.ext"
  openssl genrsa -out "$TLS_WORK/ca.key" 2048 2>/dev/null
  openssl req -x509 -new -key "$TLS_WORK/ca.key" -days 365 -subj "/CN=Harbor Lab CA" \
    -config "$TLS_WORK/ca.cnf" -extensions v3_ca -out "$TLS_WORK/ca.crt"
  openssl genrsa -out "$TLS_WORK/tls.key" 2048 2>/dev/null
  openssl req -new -key "$TLS_WORK/tls.key" -subj "/CN=${HARBOR_HOST}" \
    -config "$TLS_WORK/ca.cnf" -out "$TLS_WORK/tls.csr"
  openssl x509 -req -in "$TLS_WORK/tls.csr" -CA "$TLS_WORK/ca.crt" -CAkey "$TLS_WORK/ca.key" \
    -CAcreateserial -days 365 -extfile "$TLS_WORK/server.ext" -out "$TLS_WORK/tls.crt" 2>/dev/null
  kubectl -n harbor create secret generic harbor-tls \
    --from-file=tls.crt="$TLS_WORK/tls.crt" --from-file=tls.key="$TLS_WORK/tls.key" \
    --from-file=ca.crt="$TLS_WORK/ca.crt"
  rm -rf "$TLS_WORK"
fi

echo "[playground] Installing Harbor (chart ${HARBOR_CHART_VERSION}); this takes several minutes..."
helm repo add harbor https://helm.goharbor.io >/dev/null 2>&1 || true
helm repo update harbor >/dev/null
helm upgrade --install harbor harbor/harbor --version "$HARBOR_CHART_VERSION" \
  --namespace harbor --create-namespace \
  --values "$MANIFEST_DIR/harbor-values.yaml" \
  --wait --timeout 20m

# lab-start.yaml is also listed under bootstrap.manifests in config.yaml, so it
# may already be applied. kubectl apply is idempotent.
echo "[playground] Starting the workstation pod..."
kubectl apply -f "$MANIFEST_DIR/lab-start.yaml"
kubectl -n workstation rollout status deployment/workstation --timeout=600s
for _ in $(seq 1 60); do
  kubectl -n workstation exec deploy/workstation -- test -s /usr/local/share/ca-certificates/harbor-ca.crt 2>/dev/null && break
  sleep 5
done

# Starting content for this module.
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

echo "[playground] Creating the project inventory, its content and two users..."
create_project inventory
copy_to_harbor ghcr.io/stefanprodan/podinfo:6.14.1 inventory/podinfo:6.14.1
copy_to_harbor ghcr.io/stefanprodan/podinfo:6.15.0 inventory/podinfo:6.15.0
copy_to_harbor ghcr.io/stefanprodan/charts/podinfo:6.15.0 inventory/charts/podinfo:6.15.0
create_user inventory-dev Inventory-dev-123
create_user inventory-reader Inventory-read-123
add_member inventory inventory-dev 2
add_member inventory inventory-reader 3

echo "[playground] Ready."
kubectl -n harbor get pods
echo "[playground] Run tools in the workstation: kubectl -n workstation exec -it deploy/workstation -- sh"
echo "[playground] Harbor web portal: kubectl -n harbor port-forward svc/harbor 8443:8443, then https://harbor.localtest.me:8443"
