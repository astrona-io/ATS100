# Troubleshooting The CLI

When a `harbor` command fails, the message is short and the cause can be in four places: the context, the credential, the server address or the object itself. This part gives an order of checks that finds the cause without guessing.

## Check the context first

The most common cause is the wrong context. Look at which credential is current and what it points at:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
wst harbor context list
wst harbor info
```

The list marks the current context, and `harbor info` shows the user and the server of it. If these are not what you expect, switch with `harbor context switch` before anything else.

## Read the status code

Add `-v` (`--verbose`) to see more of what the command does, and read the status code of the failed request:

```sh
ws harbor project view does-not-exist -v
```

| Code | Usual cause |
| --- | --- |
| `401` | Wrong or stale password in the context; log in again with the same name |
| `403` | The user is signed in but the role does not allow it |
| `404` | The project, repository or reference does not exist, or the user cannot see it |
| Connection or certificate error | Wrong server address in the context, or a certificate the CLI does not trust |

A `404` for an object that exists means the current user cannot see it: private projects are invisible to non-members. Use the REST API with the same user to confirm.

## Certificate errors

A certificate error means the CLI does not trust the authority that signed Harbor's certificate. In a lab, `--skip-verify-client` at login skips the check. In real use, make the machine trust the authority instead, as you do for Docker or `oras`.

## Common pitfalls

> [!WARNING]
> - **Changing the user's password in Harbor when the context is stale.** Fix the context, not the user.
> - **Reading `404` as "does not exist".** It can also mean "not visible to this user".
> - **Skipping certificate verification in production.** Trust the authority instead.
> - **Debugging without `-v`.** The plain message hides the status code.
