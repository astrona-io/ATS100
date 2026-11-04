# Settings That Change Meaning

Some settings of `harbor.yml` have no copy in the chart because Kubernetes does the job in another way. Copying them blindly is the way to lose data or to leave an installation without TLS.

## data_volume

In Compose, `data_volume` is a directory on the host that holds the registry, database and Redis data. In Kubernetes there is no host directory to name. The chart asks for PersistentVolumeClaims through `persistence.persistentVolumeClaim.*`, and the storage class decides where the data sits. Moving the data is a copy job, not a setting.

## https.certificate and private_key

In Compose, these are file paths on the host. In the chart, the certificate comes from a Kubernetes Secret: `expose.tls.certSource` is `auto`, `secret` or `none`, and with `secret` the name is `expose.tls.secret.secretName`. Create the Secret from the old files first:

<!-- astrona:playground:renew -->

```sh
kubectl -n harbor get secret harbor-tls -o jsonpath='{.type}'
```

The command prints the type of the Secret that this playground uses, which is `kubernetes.io/tls` for a certificate and key pair. A migration creates the same kind of Secret from the old certificate and key.

## Passwords and keys

`database.password` becomes `database.internal.password`, or the settings of an external database. The `secretKey` of the old installation, stored in the Compose data, must be copied to the chart's `secretKey` before the first start; otherwise credentials stored in the database cannot be decrypted. `harbor_admin_password` only seeds a new installation and has no effect on an existing database.

## Settings that are gone

Some old sections have no counterpart because the feature changed or was removed, for example the older signing service. Check the release notes of your target version for each section of the old file before you declare the migration complete.

## Common pitfalls

> [!WARNING]
> - **Dropping the old `secretKey`.** Encrypted values in the copied database become unreadable.
> - **Starting without the TLS Secret.** `certSource: secret` with a missing Secret keeps the pods from starting.
> - **Pointing `existingClaim` at an empty claim.** The installation starts empty and looks like data loss.
> - **Assuming every section has a counterpart.** Read the release notes for removed features.
