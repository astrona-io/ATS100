# TLS Certificates And Trust

Every client that talks to Harbor checks its certificate before it sends a password or a layer. If the certificate names the wrong host, or was signed by a certificate authority the client does not trust, the client stops at the first request. This part shows where Harbor's certificate comes from, how to inspect it, and how a client learns to trust it.

## Three places a certificate can come from

A **certificate** proves a server's name to a client, and a **certificate authority** (CA) is the key that signs certificates. A client trusts a certificate when it trusts the CA that signed it and the certificate lists the host name the client used, in its **subject alternative name** (SAN) field.

`expose.tls.certSource` tells the chart where Harbor's certificate comes from:

| `certSource` | Where the certificate comes from | When to use it |
| --- | --- | --- |
| `auto` | The chart generates a CA and a certificate for `expose.tls.auto.commonName` | Labs and first tests |
| `secret` | A Secret you create, named by `expose.tls.secret.secretName`, with the keys `tls.crt` and `tls.key` | Production, with a certificate from your own CA or a public one |
| `none` | No certificate in Harbor; the ingress controller presents its default one | When the ingress controller ends TLS for the whole cluster |

With `auto`, the chart stores the generated CA and certificate in a Secret named after `nginx`, and `core` offers the CA for download. The chart generates them each time Helm renders its templates, and Helm renders them on every `helm upgrade`. So after each upgrade, `nginx` presents a certificate from a new CA, and every client must trust the new CA again. With `secret`, the CA stays the same until you replace it, and `core` only offers it for download if you also set `caSecretName` to a Secret that holds the key `ca.crt`.

## Inspect the certificate Harbor presents

This environment uses `certSource: secret`, so its certificate survives every `helm upgrade`. Before Harbor was installed, the bootstrap script created a lab CA called Harbor Lab CA and a certificate for `harbor.localtest.me` signed by it. It stored both in the Secret `harbor-tls`. Look at that Secret; list its keys, not the private key itself:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
kubectl -n harbor get secret harbor-tls -o jsonpath='{.data}' | jq 'keys'
```

The keys are `ca.crt`, `tls.crt` and `tls.key`. Now read the certificate that `nginx` actually presents on the wire. The workstation needs `openssl` for that, which it can install from the Alpine packages:

```sh
ws sh -c 'apk add --no-cache openssl >/dev/null && echo | openssl s_client -connect harbor.localtest.me:8443 \
  -servername harbor.localtest.me 2>/dev/null | openssl x509 -noout -subject -issuer -ext subjectAltName'
```

The subject and the SAN name `harbor.localtest.me`, and the issuer is Harbor Lab CA. That is why `curl` in the workstation accepts it: the host name matches, and the workstation trusts the issuer.

## How a client learns to trust Harbor

A client trusts Harbor's certificate only if it trusts the CA. There are three common ways to get there, and each client has its own place for the CA:

- **Operating system trust store.** Copy the CA to `/usr/local/share/ca-certificates/` and run `update-ca-certificates` (Debian, Ubuntu, Alpine). Tools that use the system store, such as `curl`, `regctl`, `oras`, `cosign` and the `harbor` CLI, then trust Harbor.
- **Docker Engine.** Docker reads a CA for one registry from `/etc/docker/certs.d/<host>:<port>/ca.crt`, here `/etc/docker/certs.d/harbor.localtest.me:8443/ca.crt`.
- **containerd on Kubernetes nodes.** The node's containerd needs the CA in its registry host configuration before a kubelet can pull from Harbor.

Harbor helps with the first step: `core` serves the CA at `/api/v2.0/systeminfo/getcert`. The workstation in this course fetched it there when it started. Compare the CA it downloads with the one in the Secret:

```sh
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/systeminfo/getcert | shasum -a 256
kubectl -n harbor get secret harbor-tls -o jsonpath='{.data.ca\.crt}' | base64 -d | shasum -a 256
```

Both lines print the same hash: `core` offers exactly the CA in the Secret, because `caSecretName` names the Secret `harbor-tls`. If you replace the certificate with one from your own CA, two things must follow. Harbor must offer the new CA (set `caSecretName`), and every client must fetch and trust it again. A client that still trusts only the old CA refuses the new certificate.

## What changes when you bring your own certificate

With `certSource: secret`, you create the Secret yourself, with `tls.crt`, `tls.key` and usually `ca.crt`, and you point the chart at it:

```yaml
expose:
  tls:
    enabled: true
    certSource: secret
    secret:
      secretName: harbor-tls
caSecretName: harbor-tls
```

These lines are the TLS part of this environment's release values; `helm -n harbor get values harbor` shows them. `nginx` reads the certificate from the Secret when it starts, so after you replace the Secret's content you restart it with `kubectl -n harbor rollout restart deployment/harbor-nginx`; `core` reads `ca.crt` the same way. The certificate's SAN must list the host in `externalURL`, `harbor.localtest.me` here, or every client refuses it.

You now know where Harbor's certificate comes from, how to read it on the wire, and the two halves of trust: Harbor offers the CA, and each client installs it. The open question is how the same choices look when Harbor runs on a single machine with Docker Compose.

## Common pitfalls

> [!WARNING]
> - **A certificate without the host name in its SAN.** Modern clients ignore the subject's common name; the SAN must list the host clients use.
> - **Replacing the certificate but not the trust.** Clients that trusted the old CA refuse a certificate from a new one until they trust the new CA.
> - **Running `helm upgrade` on a release with `certSource: auto`.** The chart generates a new CA and certificate on every upgrade, so every client must trust the new CA again. A fixed CA in a Secret, with `certSource: secret`, keeps the same certificate across upgrades.
> - **Forgetting `caSecretName` with `certSource: secret`.** Harbor then offers no CA for download, and the portal's download link is missing.
> - **Expecting `nginx` to reload a changed Secret.** Restart it after you replace the certificate.
