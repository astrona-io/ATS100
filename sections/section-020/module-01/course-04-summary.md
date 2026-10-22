# Summary

Two settings decide whether a fresh Harbor works for its clients: the address it believes clients use, and the certificate it presents on that address. Both are chosen at install time, in the Helm values or in `harbor.yml`.

## What you learned

The `harbor-helm` chart installs Harbor as a Helm release, and `helm get values`, `helm upgrade` and `helm history` read, change and track it. `expose.type` decides what sits in front of Harbor: an Ingress, or a ClusterIP, NodePort or LoadBalancer Service in front of `nginx`. `persistence` decides whether data survives a pod, and `harborAdminPassword` only sets the first password.

`externalURL` is the address `core` gives to clients, most importantly as the token realm in the registry's `WWW-Authenticate` header. When it names a host clients cannot reach, every push fails at the token step, while the portal and the health report look fine. The fix is a `helm upgrade` with the correct value, written down in a values file, not turning TLS off.

The certificate comes from one of three sources: `auto`, where the chart generates a CA and a certificate; `secret`, where you provide them in a Secret; and `none`, where the ingress controller presents its own. A client trusts Harbor when it trusts the CA and the certificate's SAN lists the host it used. `core` serves the CA at `/api/v2.0/systeminfo/getcert`, and with `certSource: secret` it needs `caSecretName` to do so. After a certificate change, `nginx` must restart and every client must trust the new CA.

The Docker Compose installers configure the same choices in `harbor.yml`: `hostname` and `external_url` for the address, `https.certificate` and `https.private_key` for the certificate, `data_volume` for storage. `./prepare` turns the file into configuration, and `./install.sh --with-trivy` starts Harbor with its scanner. Key facts to remember:

- The token realm is `externalURL` plus `/service/token`.
- A certificate's SAN must list the host in `externalURL`.
- Replacing a certificate means restarting `nginx` and re-trusting the CA on every client.
- A changed `harbor.yml` needs `prepare` before it takes effect.

<!-- astrona:playground:destroy -->
