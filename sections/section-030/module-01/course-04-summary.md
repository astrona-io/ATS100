# Summary

The `harbor` CLI turns Harbor's REST API into commands you can type, repeat and script. Working with it safely comes down to one habit: always know which saved credential it uses.

## What you learned

`harbor login` checks a user name and password against a server and saves them as a named credential, the context, in `$HOME/.config/harbor-cli/config.yaml`. The `--config` flag and the `HARBOR_CLI_CONFIG` variable point the CLI at another file. Every command uses the credential named by `current-credential-name`, and each login makes its credential current. Passwords are encrypted with AES-GCM and a key from `HARBOR_ENCRYPTION_KEY`, the system keyring or, as a fallback with a warning, a file under `~/.harbor/keyring/`.

`harbor context list`, `switch`, `get`, `update` and `delete` manage the saved credentials, and `harbor logout` removes the current one. A context does not notice when a password changes or a server moves; it keeps failing with `401` or a connection error until you log in again with the same name or switch to another context. Fix the context, never the user's password in Harbor.

The everyday commands follow Harbor's structure: `harbor health` and `harbor info` for the server, `harbor project list`, `harbor repo list <project>` and `harbor artifact list <project>/<repository>` for content. They show only what the current user may see. The global `-o` flag gives JSON, YAML or CSV, and JSON with `jq` is the reliable way to script. Key facts to remember:

- The last login decides which server and user the next command uses.
- `--password-stdin` keeps passwords out of shell history.
- The configuration file and the keyring file together can decrypt every saved password.
- Scripts pass `project/repository` explicitly and read JSON, not tables.

<!-- astrona:playground:destroy -->
