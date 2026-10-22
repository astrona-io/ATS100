# Signing In And Where The CLI Keeps Credentials

Before the `harbor` CLI can do anything, it needs a server address, a user name and a password. It does not ask for them every time: it saves them, once, in a configuration file. This part signs the CLI in, opens that file, and explains how the password is protected, so that you know exactly what the CLI uses when you run a command.

## Sign in

`harbor login` checks a user name and password against a Harbor server and, if they work, saves them as a **credential**: a named entry with the server address, the user name and the encrypted password. The server address is the last argument. `--context-name` (short `-n`) names the credential; without it, the CLI builds a name from the user and the server.

<!-- astrona:playground:renew -->

Sign in as the developer user:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username inventory-dev \
  --password Inventory-dev-123 --context-name inventory-dev
```

The CLI prints a line saying the login succeeded for `inventory-dev` at the server. It may also print a warning that the system keyring is not available; that warning is explained below. Now run a command that needs the credential:

```sh
ws harbor project list
```

The table lists the project `inventory`. The CLI read the saved credential, sent it to `core` with each API request, and `core` returned only the projects `inventory-dev` may see.

`--password` on the command line ends up in your shell history and in the process list. For real work, pass it on standard input with `--password-stdin` instead, for example `printf '%s' "$HARBOR_PASSWORD" | harbor login ... --password-stdin`.

## The configuration file

The CLI keeps its credentials in one YAML file. By default it is `$HOME/.config/harbor-cli/config.yaml`; in the workstation that is `/root/.config/harbor-cli/config.yaml`. Two things can point the CLI at another file: the global flag `--config` (short `-c`), and the environment variable `HARBOR_CLI_CONFIG`. The flag wins over the variable, and the variable wins over the default.

Look at the file:

```sh
ws cat /root/.config/harbor-cli/config.yaml
```

The file has a key `current-credential-name`, set to `inventory-dev`, and a list `credentials`. Each entry has `name`, `username`, `password` and `serveraddress`. The password is not readable: it is encrypted. Every command uses the credential that `current-credential-name` names, which is why the most recent `harbor login` decides which server and user your next command uses.

## How the password is encrypted

The CLI encrypts each password with AES-GCM, a standard encryption method, and a key it keeps outside the configuration file. It looks for that key in three places, in this order:

1. The environment variable `HARBOR_ENCRYPTION_KEY`, if it is set.
2. The operating system keyring, such as the macOS Keychain or the Secret Service on a Linux desktop.
3. A file under `~/.harbor/keyring/`, when no system keyring is available. The CLI warns when it uses this fallback.

The workstation is a plain Alpine container without a system keyring, so the CLI uses the file fallback. List the folder:

```sh
ws ls -l /root/.harbor/keyring/
```

There is one file, readable only by its owner. Anyone who can read both this file and the configuration file can decrypt the passwords, so treat the pair like a password store. On a build server, set `HARBOR_ENCRYPTION_KEY` from the server's secret store instead, so that no key lies on disk.

The workstation keeps both files inside the container. A restart of the workstation pod removes them, and you have to sign in again.

You now know what `harbor login` saves, where it saves it, and how the password is protected. One credential is enough for one user on one server; the next question is how to keep several apart.

## Common pitfalls

> [!WARNING]
> - **Assuming the last login does not matter.** Every command uses the credential in `current-credential-name`, and a login changes it.
> - **Passing passwords with `--password` in scripts.** Use `--password-stdin` so the password stays out of shell history and process lists.
> - **Copying `config.yaml` to another machine.** The passwords in it cannot be decrypted without the key, which stays behind in the keyring.
> - **Ignoring the keyring warning on a shared machine.** The fallback file is a key; protect it like one, or use `HARBOR_ENCRYPTION_KEY`.
