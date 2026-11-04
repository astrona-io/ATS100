# Signing In From A Pipeline

A pipeline needs a credential, and the credential must not end up in logs, in shell history or in a repository. This part chooses an account type and passes the password the safe way.

## Use an account made for it

Do not run a pipeline as `admin`. Create a **robot account** in the project, with only the permissions the job needs, and give it an expiry. A robot account is a non-human Harbor account with a token and a limited set of permissions, so a leaked token opens far less than a leaked administrator password. Robot accounts are created in the web portal or with the REST API.

## Pass the password without history

`--password` on the command line shows in the process list and in the shell history. Read the secret from standard input or from a variable that the pipeline fills from its secret store:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
echo 'Inventory-read-123' | ws harbor login https://harbor.localtest.me:8443 \
  --username inventory-reader --password-stdin --context-name reader --skip-verify-client
ws harbor context list
```

The first command reads the password from standard input, so it is not part of the command line. The second lists the saved contexts and shows `reader`. Verify the flag exists in your version with `harbor login --help`.

## One config file per job

The CLI saves credentials in its configuration file. Give each job its own file with the global `--config` flag, or with the `HARBOR_CLI_CONFIG` variable, and delete it when the job ends. Then no job can use the credential of another, and a stale context does not carry from run to run.

## Common pitfalls

> [!WARNING]
> - **Using the administrator in a pipeline.** Use a robot account with the least permissions and an expiry.
> - **Passing `--password` in the command line.** Use standard input or a secret variable.
> - **Sharing one config file between jobs.** Jobs overwrite each other's current context.
> - **Printing the config file in a log.** Together with its key file it can decrypt the saved passwords.
