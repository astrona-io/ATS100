# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Harbor exposure

## Scenario

A colleague changed a setting of the Harbor release `harbor` in the namespace `harbor` and left. Since then, `docker login` and pushes from clients fail, although the portal and the health API still answer. The address that users must use is `https://harbor.localtest.me:8443`.

Client tools run in the workstation pod:

```sh
kubectl -n workstation exec -i deploy/workstation -- curl -sSI https://harbor.localtest.me:8443/v2/
```

## Your task

1. Find the setting that makes Harbor send clients to the wrong address.
2. Correct it on the existing release.
3. Prove that clients are sent to the right address and that a push works.

## Constraints

- Do not uninstall or reinstall the release.
- Keep all other values of the release, including the certificate settings.
- Do not edit Secrets by hand.

## Done when

- The Helm value `externalURL` is `https://harbor.localtest.me:8443`.
- The `WWW-Authenticate` header of `/v2/` names the realm `https://harbor.localtest.me:8443/service/token`.
- `expose.tls.certSource` is still `secret` with the Secret `harbor-tls`.
- Every component is healthy and a push to `inventory` works.
