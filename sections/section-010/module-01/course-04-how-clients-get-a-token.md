# How Clients Get A Token

A `docker login` or an `oras push` is not one request. The client asks the registry, gets refused, asks Harbor for a token, and asks the registry again. Each step involves a different component, so knowing the steps tells you where to look when a login or a push fails with `401` or `403`.

## The four steps

1. The client calls `/v2/` on Harbor without a credential.
2. Harbor answers `401 Unauthorized` and puts a `WWW-Authenticate` header in the answer. It names the token service, the `realm`, and the `service` name.
3. The client sends its user name and password to the realm address and asks for a token for a **scope**, such as `repository:inventory/podinfo:push,pull`. `core` checks the credential and the role of the user in the project, and returns a signed token that lists the actions it allows.
4. The client repeats its request with the token. `registry` checks the signature of the token and the actions in it, and serves the request.

## See the first two steps

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -sSI https://harbor.localtest.me:8443/v2/
```

The answer is `401` with a `www-authenticate` header that has a `realm` ending in `/service/token`. Harbor builds the realm from its external URL, so a wrong external URL sends clients to a wrong address in step 3.

Ask for a token as the Guest user, the way a client does, for a repository where that user may only pull:

```sh
ws sh -c 'curl -sS -u inventory-reader:Inventory-read-123 "https://harbor.localtest.me:8443/service/token?service=harbor-registry&scope=repository:inventory/podinfo:push,pull" | jq -r ".token" | cut -c1-20'
```

The command prints the first characters of a token, because Harbor issues a token even when the user may not push; the token lists only the actions the role allows. A later push with that token is refused with `403`.

## Which error means what

| Answer | Meaning | Where to look |
| --- | --- | --- |
| `401` at step 1 | Normal; it starts the token flow | Nothing |
| `401` at step 3 | Wrong user name or password, or a disabled account | The credential |
| `403` at step 4 | The token does not allow the action | The role of the user in the project |
| Connection error at step 3 | The realm address is not reachable | `externalURL` and DNS |

## Common pitfalls

> [!WARNING]
> - **Treating the first `401` as a failure.** It is the normal start of the token flow.
> - **Blaming the password for a `403`.** A `403` means the sign-in worked and the role is too small.
> - **Printing tokens into logs.** A token works until it expires; treat it as a password.
> - **Testing only the portal.** The portal uses a session, not this flow, so it can work while clients fail.
