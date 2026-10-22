# Contexts For More Than One Server Or User

An operator works with a test Harbor and a production Harbor, as an administrator and as a normal user. Signing in again every time you switch is slow, and a mistake sends a command to the wrong server. The `harbor` CLI saves each credential as a **context**, and you choose which one is current. This part saves several contexts, switches between them, and repairs a context that went stale.

## Save a second credential

Each `harbor login` with a new `--context-name` adds a credential to the list and makes it current. Save one for the read-only user next to the developer credential:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username inventory-dev \
  --password Inventory-dev-123 --context-name inventory-dev
ws harbor login https://harbor.localtest.me:8443 --username inventory-reader \
  --password Inventory-read-123 --context-name inventory-reader
ws harbor context list
```

`harbor context list` shows both contexts, `inventory-dev` and `inventory-reader`, and marks `inventory-reader` as the current one, because it was saved last.

## Switch and read

`harbor context switch` changes `current-credential-name` without signing in again. `harbor context get` reads one field of the current credential, so a script can check where it is pointed before it does anything:

```sh
ws harbor context switch inventory-dev
ws harbor context get credentials.username
ws harbor context get credentials.serveraddress
```

The two `get` commands print `inventory-dev` and `https://harbor.localtest.me:8443`. Add `--name <context>` to read a field of another context without switching to it.

## Repair a stale context

Passwords change, and servers move. A context does not notice either; it keeps the old values until you change them, and every command fails with `401` or a connection error. Save a context with a wrong password to see it. `--skip-verify-client` saves the credential without checking it against the server first:

```sh
ws harbor login https://harbor.localtest.me:8443 --username inventory-dev \
  --password Wrong-password-1 --context-name inventory-dev-stale --skip-verify-client
ws harbor project list
```

The listing fails with an authentication error from `core`: the CLI sent the stale password of the current context, `inventory-dev-stale`. Two ways repair a stale context. The simplest is to run `harbor login` again with the same `--context-name` and the right password; the CLI updates the existing credential and encrypts the new password. The other is to switch to a context that still works. Do the first:

```sh
ws harbor login https://harbor.localtest.me:8443 --username inventory-dev \
  --password Inventory-dev-123 --context-name inventory-dev-stale
ws harbor project list
```

The listing works again. `harbor context update credentials.serveraddress <url>` changes a single field in place, which is handy when a server moves but the password stays the same.

## Remove what you no longer need

Old contexts are a risk: they hold working passwords you forgot about. `harbor context delete --current` removes the current credential; `harbor logout` does the same and asks for confirmation unless you add `--yes`. Remove the extra context:

```sh
ws harbor context switch inventory-dev-stale
ws harbor logout --yes
ws harbor context list
```

The list shows `inventory-dev` and `inventory-reader` again. After a logout, no context is current until you switch to one, so run `harbor context switch inventory-dev` before the next command.

You can now keep several contexts, switch between them, read where the current one points, and repair or remove a stale one. Which command to run once the right context is current is the remaining question.

## Common pitfalls

> [!WARNING]
> - **Not checking the current context before a change.** Run `harbor context get credentials.serveraddress` first, especially when one of your contexts is production.
> - **Using `--skip-verify-client` by habit.** It saves credentials that may not work; the error only shows on the next command.
> - **Editing the password in `config.yaml` by hand.** The file holds encrypted passwords; a plain one will not decrypt. Run `harbor login` again instead.
> - **Fixing a stale context by changing the user's password in Harbor.** That breaks every other client that uses the right password. Fix the context.

## Your mission: Point The Harbor CLI At The Right Server

You can now read which context the CLI uses, switch it, and renew a stale password. The graded lab gives you a workstation whose CLI fails, and asks you to make it list projects as the developer user on the right server.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-100-playground-030-01
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-030/module-01/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-01/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-100-lab-030-01
astrona start ats-100-playground-030-01
```
