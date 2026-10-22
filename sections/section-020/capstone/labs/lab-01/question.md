# Question

Solve this question on: `terminal`

**Time:** about 35 minutes · **Topic:** TLS for Harbor

## Scenario

The security team wants Harbor to stop using the certificate the Helm chart generated. Every certificate must come from the team's own certificate authority, **Inventory Lab CA**. A colleague started the change and went on holiday:

- The CA's certificate and key are in the Secret `lab-ca` in the namespace `harbor` (keys `ca.crt` and `ca.key`).
- The release `harbor` already serves its certificate from the Secret `harbor-tls` and offers the CA for download from the same Secret.
- Since the change, every HTTPS request from the workstation pod fails.

## Your task

1. Find why HTTPS requests from the workstation fail. There is more than one reason.
2. Issue a new certificate for `harbor.localtest.me` signed by the Inventory Lab CA, and make Harbor serve it from the Secret `harbor-tls`. The Secret must keep the keys `tls.crt`, `tls.key` and `ca.crt`.
3. Make the workstation trust Harbor again, without any `--insecure` option.

The workstation pod can install `openssl` with `apk add --no-cache openssl`. The administrator is `admin` with the lab-only password `Harbor12345`.

## Constraints

- Keep TLS on, keep `certSource: secret` with the Secret `harbor-tls`, and keep `externalURL` at `https://harbor.localtest.me:8443`.
- Sign the certificate with the Inventory Lab CA in `lab-ca`. Do not create a new CA, and do not go back to the chart's generated certificate.
- Do not reinstall Harbor.

## Done when

- The release values have TLS on, `certSource: secret`, the secret name `harbor-tls` and the right `externalURL`.
- The certificate Harbor presents verifies for `harbor.localtest.me` against the Inventory Lab CA.
- `/api/v2.0/systeminfo/getcert` returns the Inventory Lab CA.
- The workstation reaches Harbor over HTTPS with its normal trust store, and a push to `inventory` succeeds.
