# Verifying The Installation

A Helm install that returns without an error says that Kubernetes accepted the objects. It does not say that clients can use Harbor. This part gives a short list of checks that you run after every install or change, in the order in which they find problems.

## The checks

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
kubectl -n harbor get pods
ws sh -c 'curl -sS https://harbor.localtest.me:8443/api/v2.0/health | jq ".components[] | {name, status}"'
ws sh -c 'curl -sS https://harbor.localtest.me:8443/api/v2.0/systeminfo | jq "{harbor_version, external_url: .external_url}"'
ws curl -sSI https://harbor.localtest.me:8443/v2/
ws sh -c 'echo test > /tmp/verify.txt && cd /tmp && oras login harbor.localtest.me:8443 -u admin -p Harbor12345 && oras push harbor.localtest.me:8443/inventory/verify:1 verify.txt:text/plain'
```

Read each answer for what it proves:

1. **Pods.** Every pod is `Running` and ready. A pod in `CrashLoopBackOff` or `Pending` is the first lead.
2. **Health API.** Every component is `healthy`. The portal can load while `registry` is down.
3. **System information.** The Harbor version is the one you installed and `external_url` is the address clients use.
4. **The `/v2/` header.** The `realm` names the right host. A wrong host breaks every `docker login`.
5. **A real push.** A push through the same path as clients tests the certificate, the token flow and the storage together.

If any step fails, stop and fix that one before you continue; a later check often passes or fails for the same reason.

## Record what you checked

Write the date, chart version, Harbor version and the result of each check in the change record. A later reader can then tell what was verified and compare with a new installation.

## Common pitfalls

> [!WARNING]
> - **Calling an install done when `helm install` returns.** It means the objects were accepted, not that Harbor works.
> - **Testing from the same machine as the install only.** Test from where the clients are.
> - **Skipping the push.** It is the one check that covers certificate, token flow and storage together.
> - **Checking once.** Check again after a restart, because some problems appear only at the next start.
