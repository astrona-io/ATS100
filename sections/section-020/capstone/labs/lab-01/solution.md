# Solution: Serve Harbor With Your Own Certificate

Work the task yourself first. Running `astrona submit -c sections/section-020/capstone/labs/lab-01` after a step tells you which checks pass.

The grader checks four things: the release values, the presented certificate against the lab CA, the CA Harbor offers for download, and the workstation's trust with a push.

## Step 1: See what fails, and why

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/ping
```

`curl` refuses the certificate. Read what Harbor presents, ignoring trust for a moment:

```sh
ws sh -c 'apk add --no-cache openssl >/dev/null && echo | openssl s_client -connect harbor.localtest.me:8443 \
  -servername harbor.localtest.me 2>/dev/null | openssl x509 -noout -subject -issuer -ext subjectAltName'
```

There are two faults. The certificate was issued for `harbor.example.com`, so its SAN does not list `harbor.localtest.me`. And the issuer is Inventory Lab CA, which the workstation does not trust yet: it still trusts the CA it downloaded at start, the one the chart generated.

## Step 2: Issue a certificate for the right host

Copy the CA out of the Secret onto your machine, then into the workstation, where `openssl` runs:

```sh
kubectl -n harbor get secret lab-ca -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
kubectl -n harbor get secret lab-ca -o jsonpath='{.data.ca\.key}' | base64 -d > ca.key
ws sh -c 'mkdir -p /tmp/pki && cat > /tmp/pki/ca.crt' < ca.crt
ws sh -c 'cat > /tmp/pki/ca.key' < ca.key
```

Create a key and a certificate signing request for `harbor.localtest.me`, and sign it with the CA. The SAN goes in a small extension file, because `openssl x509 -req` does not copy it from the request:

```sh
ws sh -c 'cd /tmp/pki &&
  openssl req -newkey rsa:2048 -nodes -subj "/CN=harbor.localtest.me" -keyout tls.key -out tls.csr &&
  printf "subjectAltName=DNS:harbor.localtest.me\n" > san.ext &&
  openssl x509 -req -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 90 -extfile san.ext -out tls.crt'
ws cat /tmp/pki/tls.crt > tls.crt
ws cat /tmp/pki/tls.key > tls.key
```

## Step 3: Replace the Secret and restart nginx and core

Replace the content of `harbor-tls`, keeping its three keys:

```sh
kubectl -n harbor create secret generic harbor-tls --from-file=tls.crt=tls.crt \
  --from-file=tls.key=tls.key --from-file=ca.crt=ca.crt --dry-run=client -o yaml | kubectl apply -f -
kubectl -n harbor rollout restart deployment/harbor-nginx deployment/harbor-core
kubectl -n harbor rollout status deployment/harbor-nginx
kubectl -n harbor rollout status deployment/harbor-core
```

`nginx` reads the certificate and `core` reads `ca.crt` only when they start, which is why both restart. The release values are already right (`helm -n harbor get values harbor` shows `certSource: secret`, `secretName: harbor-tls` and `caSecretName: harbor-tls`), so no `helm upgrade` is needed. Delete the copies of `ca.key` and `tls.key` on your machine when you are done.

## Step 4: Make the workstation trust the new CA

The workstation downloads Harbor's CA from `/api/v2.0/systeminfo/getcert` when it starts. Restart it so it fetches the Inventory Lab CA:

```sh
kubectl -n workstation rollout restart deployment/workstation
kubectl -n workstation rollout status deployment/workstation
```

## Step 5: Prove the result

```sh
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/ping
ws regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
ws regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

The ping answers, and the copy succeeds without any `--insecure` option.

## Step 6: Submit

```sh
astrona submit -c sections/section-020/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Going back to `certSource: auto` | The workstation works again, but the certificate does not come from the Inventory Lab CA |
| A self-signed certificate for `harbor.localtest.me` | It does not verify against the Inventory Lab CA |
| Restarting only the workstation | It trusts the new CA, but the certificate still names `harbor.example.com` |
| `--insecure` on every client | Every client stops checking certificates; the task forbids it |
