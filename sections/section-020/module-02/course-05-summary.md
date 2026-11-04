# Summary

Exposure, persistence and secrets are three groups of chart settings, and each has one value that does most of the damage when it is wrong.

## What you learned

`expose.type` selects how clients reach Harbor: `ingress`, `clusterIP`, `nodePort` or `loadBalancer`. `externalURL` is separate: it is the address Harbor tells its clients to use, and it builds the token realm in the `WWW-Authenticate` header of `/v2/`. A wrong `externalURL` leaves the portal working and breaks `docker login`.

`persistence.enabled` creates the claims for the components that keep data; with `false` the data is lost when a pod is replaced. `persistence.imageChartStorage` moves image data to object storage. The chart's secrets are `secretKey` (16 characters, never changed on a running installation), `harborAdminPassword` (first start only), the internal secrets and the TLS Secret; existing Secrets keep them out of the values file. Every change is a `helm upgrade --reuse-values` that is previewed with `--dry-run` and checked afterwards. Key facts to remember:

- `externalURL` decides where clients are sent for a token.
- Set your own `secretKey` before the first start.
- `--reuse-values` keeps the rest of the configuration.
- Check the realm, health and a push after every change.

<!-- astrona:playground:destroy -->
