# Section 030: The Harbor Command-Line Tool

The web portal is fine for looking around, but daily work and every script need a command line. The `harbor` command-line tool (CLI) from the Harbor project calls the same REST API the portal uses, so anything you can click you can also type, repeat and automate. This section signs the CLI in, keeps several servers and users apart with contexts, and turns its output into data a script can use.

**Topic covered:** The Harbor CLI

## What you will learn

- Signing in with `harbor login`, and what the CLI stores in its configuration file.
- How the CLI encrypts passwords, and where it keeps the encryption key.
- Working with several credentials: `harbor context list`, `switch`, `get`, `update` and `delete`, and `harbor logout`.
- Everyday commands: `harbor info`, `harbor health`, `harbor project list`, `harbor repo list`, `harbor artifact list`.
- Output formats: tables for people, JSON, YAML and CSV for scripts.

## The learning path

Work through the module in order. It has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The landing page starts the module's playground.

### 1. Work With Harbor From The Command Line

The playground holds Harbor 2.15.4 with the project `inventory`, three artifacts in it, and two users: `inventory-dev` (Developer) and `inventory-reader` (Guest).

1. Signing In And Where The CLI Keeps Credentials
2. Contexts For More Than One Server Or User, followed by the lab **Point The Harbor CLI At The Right Server**
3. Everyday Commands And Output Formats
4. Summary

## Section capstone: Build A Repository Report With The Harbor CLI

The capstone asks for a report of every artifact in `inventory` with its digest, made with read-only rights in a context of its own, and checked against what Harbor stores. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-030/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-100-capstone-030
```
