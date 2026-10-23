# Solution: Fix The External URL Of A Helm Install

Work the task yourself first. Running `astrona submit -c sections/section-020/module-01/labs/lab-01` after a step tells you which checks pass.

The grader checks three things: `externalURL` in the release values, the token realm the registry announces, and TLS still on with a push that succeeds.

## Step 1: Read what the registry tells the client

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -sSI https://harbor.localtest.me:8443/v2/
```

The status is `401`, as always for a request without a token. The `WWW-Authenticate` header names the realm `https://harbor.example.com/service/token`. Every client follows that header to get a token, and `harbor.example.com` is not this Harbor, so the push fails before the registry ever sees the upload.

## Step 2: Find where the realm comes from

The realm is `externalURL` plus `/service/token`. Read the release values and history:

```sh
helm -n harbor get values harbor
helm -n harbor history harbor
```

The values show `externalURL: https://harbor.example.com`, and the history shows a second revision: the upgrade that changed it.

## Step 3: Write the values down and upgrade

Save the full, correct values as `harbor-values.yaml`:

```yaml
expose:
  type: clusterIP
  tls:
    enabled: true
    certSource: secret
    secret:
      secretName: harbor-tls
  clusterIP:
    name: harbor
    ports:
      httpPort: 8080
      httpsPort: 8443
externalURL: https://harbor.localtest.me:8443
caSecretName: harbor-tls
harborAdminPassword: Harbor12345
persistence:
  enabled: false
trivy:
  enabled: true
metrics:
  enabled: false
redis:
  internal:
    image:
      repository: docker.io/valkey/valkey
      tag: 8.1.10-alpine
```

The TLS lines keep the lab certificate from the Secret `harbor-tls`, so the upgrade does not change the certificate and the workstation still trusts it. The `redis` lines keep the multi-architecture Valkey image that replaces the bundled Redis.

Apply it with an upgrade of the release:

```sh
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 \
  --values harbor-values.yaml --wait --timeout 15m
```

An alternative is `helm get values harbor -n harbor -o yaml > harbor-values.yaml`, then editing only the `externalURL` line. Both give the same release.

## Step 4: Prove the fix

```sh
helm -n harbor get values harbor -o json | jq -r '.externalURL'
ws curl -sSI https://harbor.localtest.me:8443/v2/
ws regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
ws regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

The value is `https://harbor.localtest.me:8443`, the realm names `https://harbor.localtest.me:8443/service/token`, and the copy succeeds. If the first push still fails, wait half a minute: `core` restarts after the upgrade.

## Step 5: Submit

```sh
astrona submit -c sections/section-020/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `helm upgrade` with only `--set externalURL=...` and no `--reuse-values` | Helm falls back to the chart defaults for every other value: `ingress`, a new certificate and `persistence` on |
| Turning TLS off | The realm is still wrong, and TLS is graded |
| Uninstalling and installing again | Every artifact is lost, because nothing is persisted, and the task forbids it |
