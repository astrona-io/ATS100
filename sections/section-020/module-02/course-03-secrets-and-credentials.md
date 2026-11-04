# Secrets And Credentials

A Harbor installation holds several secrets, and they differ in what they protect and in what happens when they change. This part lists them, shows which ones you should set yourself, and shows how to keep them out of the values file.

## The secrets of the chart

| Setting | Protects | Note |
| --- | --- | --- |
| `harborAdminPassword` | The first password of `admin` | Used at the first start only; later changes are made in Harbor |
| `secretKey` | Encryption of stored credentials in the database | Exactly 16 characters; changing it makes stored values unreadable |
| `core.secret`, `jobservice.secret`, `registry.secret` | Calls between components | Generated when empty |
| `core.xsrfKey` | Protection against forged requests | Generated when empty |
| `expose.tls.secret.secretName` | The certificate and key | The Secret `harbor-tls` in this course |
| `database.internal.password` | The internal PostgreSQL user | Change it for a real installation |

The chart default for `secretKey` is a fixed public string. Every installation that keeps it shares the same encryption key, so set your own before the first start.

## Look without printing values

List the Secrets and read only the key names of one:

<!-- astrona:playground:renew -->

```sh
kubectl -n harbor get secrets
kubectl -n harbor get secret harbor-tls -o jsonpath='{.data}' | jq 'keys'
```

The second command prints the names of the keys, such as `tls.crt` and `tls.key`, and not their content. Never print secret values into a terminal that is shared or recorded.

## Use existing Secrets

Instead of writing values into the values file, the chart can read some of them from Secrets that you create yourself. `existingSecretAdminPassword` names a Secret with the administrator password (key `HARBOR_ADMIN_PASSWORD` by default), `existingSecret` under `core` names one for the core secrets, and `secretKey` has an existing-secret option as well in recent chart versions. Keeping these in Secrets lets you manage them with a tool for secrets and keeps them out of Git.

## Changing a secret later

A changed `harborAdminPassword` does not change the password of an existing `admin` account. Change that password in Harbor. A changed `secretKey` is worse: stored credentials, such as registry endpoint passwords, can no longer be decrypted. Treat `secretKey` as permanent and back it up with the database.

## Common pitfalls

> [!WARNING]
> - **Keeping the default `secretKey`.** It is public. Set your own 16 characters before the first start.
> - **Changing `secretKey` on a running installation.** Stored credentials become unreadable.
> - **Committing a values file with passwords.** Use existing Secrets or a secrets tool.
> - **Expecting `harborAdminPassword` to reset the admin password.** It only seeds the first start.
