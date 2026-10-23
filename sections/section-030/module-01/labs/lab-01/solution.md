# Solution: Point The Harbor CLI At The Right Server

Work the task yourself first. Running `astrona submit -c sections/section-030/module-01/labs/lab-01` after a step tells you which checks pass.

The grader checks three things: the user and server of the current credential, a working `harbor project list` that shows `inventory`, and the unchanged Harbor password.

## Step 1: Find the current context

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
wst harbor context list
ws harbor context get credentials.serveraddress
```

The `harbor` CLI (version 0.0.27) draws lists and views as a table only on a terminal, so these commands run through `wst`, which adds `-t` (a terminal) to `kubectl exec`.

There are two contexts. The current one, `inventory-dev-old-server`, points at `https://harbor.example.com:8443`, a server that does not exist here, so every command fails with a connection error. The other context, `inventory-dev`, points at the right server.

## Step 2: Switch and try

```sh
ws harbor context switch inventory-dev
wst harbor project list
```

The server is right now, but the command fails with an authentication error from `core`: the context `inventory-dev` holds an old password.

## Step 3: Renew the password

Run `harbor login` again with the same context name and the right password. The CLI checks the password against Harbor, then updates the saved credential and makes it current:

```sh
ws harbor login https://harbor.localtest.me:8443 --username inventory-dev \
  --password Inventory-dev-123 --context-name inventory-dev
```

## Step 4: Prove the fix

```sh
ws harbor context get credentials.username
ws harbor context get credentials.serveraddress
wst harbor project list
```

The current credential is `inventory-dev` at `https://harbor.localtest.me:8443`, and the listing shows `inventory`. You can remove the stale context with `harbor context switch inventory-dev-old-server`, then `harbor logout --yes`, and switch back to `inventory-dev`; the grader does not require it.

## Step 5: Submit

```sh
astrona submit -c sections/section-030/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Signing in as `admin` | The CLI works, but as the wrong user; the grader checks the user name |
| Changing `inventory-dev`'s password in Harbor to the old one | The CLI works, but every other client of that user breaks; the grader checks the password |
| Editing the password in `config.yaml` by hand | The file holds encrypted passwords; a plain one does not decrypt |
