# Installing, Pinning And Troubleshooting

A script that works today can break when the CLI is upgraded, because the tool is young and its flags change. This part keeps the version under control and shows what to do when a command fails.

## Know and pin the version

The CLI reports its version with `harbor version`:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor version
```

The workstation pod has version v0.0.27. In your own pipelines, install a fixed release of the CLI, for example from the release page of the project, and write the version in the pipeline file. Upgrade it on purpose, read the changes, and rerun your scripts against a test Harbor. Do not install "the latest" in a job.

## Check the flags of your version

Flags and subcommands change, so look at the help of the version you run before you write a script:

```sh
ws harbor project create --help
ws harbor artifact tags --help
```

The help lists the flags, including required ones such as `--storage-limit`. Keep a note of what you verified for which version.

## Find out why a command failed

Add `-v` (`--verbose`) to a command to see more of what it does, and compare with a call to the REST API using `curl` and the same user. Every CLI command is an API call, so the REST API is the fallback when the CLI has no command for a task, and it is available in every version of Harbor.

```sh
ws harbor project view does-not-exist -v
```

The output shows more detail than the plain error. A `401` points at the credential, a `403` at the role, a `404` at a wrong name, and a connection error at the address or the certificate.

## Common pitfalls

> [!WARNING]
> - **Installing the latest CLI in every run.** A new release can change a flag. Pin the version.
> - **Copying a command from the documentation of another version.** Check `--help` on the version you run.
> - **Reading only the last line of an error.** Add `-v` and read the status code.
> - **Fighting the CLI when it has no command.** Use the REST API.
