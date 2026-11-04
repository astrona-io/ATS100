# Summary

A scripted `harbor` command is a command that never asks, returns data and reports its result by exit code.

## What you learned

Pass every argument, use `-i` without a terminal, and use `-o json` with `jq`; list output sits under `Payload`, and `tags[]?` handles artifacts without tags. Check the exit code after each command and stop on failure. A bulk change has three steps: list the candidates, print the commands with `echo`, then run them. Remove tags with `harbor artifact tags delete`, never with `artifact delete`.

In a pipeline, use a robot account with the least permissions and an expiry, pass the password through standard input, and give each job its own configuration file. Pin the CLI version, read `--help` for the version you run, and add `-v` when a command fails. The REST API covers what the CLI does not. Key facts to remember:

- No prompts, no tables, no unchecked exit codes.
- Print a bulk change before you run it.
- Robot accounts, not `admin`, in pipelines.
- Pin the CLI version.

<!-- astrona:playground:destroy -->
