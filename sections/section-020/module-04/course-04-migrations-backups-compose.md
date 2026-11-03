# Database Migrations, Backups And Compose Upgrades

A Helm rollback restores Kubernetes objects. It does not restore data. This difference decides whether a rollback is safe, and it explains why a backup matters. This part explains what `core` does to the database on start and how the Docker Compose installers handle the same upgrade.

## What core does to the database

When `core` starts, it compares the schema version of the PostgreSQL database with the version it needs, and it runs the missing migration steps. A migration changes tables and columns, and it runs once. The new schema stays after a Helm rollback, because Helm does not touch the database.

This gives two cases:

- **A change within the same Harbor version**, such as a log level, an image tag fix or a resource limit: a rollback is safe, because the schema did not change.
- **An upgrade to a new Harbor version that has migrated the database**: the older `core` may not work with the newer schema. The way back is to restore the database and the registry storage from the backup, and then run the older release.

Check the schema version that `core` expects in its log after a start:

<!-- astrona:playground:renew -->

```sh
kubectl -n harbor logs deployment/harbor-core | grep -i migrat | head -n 5
```

The log lines mention the migration and the version reached. If the command prints nothing, the log has rotated or the database was already current; the check still tells you where to look.

## Back up and restore in outline

Back up the database with `pg_dump` inside the `database` pod, and the registry storage with the method your storage provides (a volume snapshot, or a copy of the bucket). In this playground nothing is persisted, so there is nothing worth saving, but the shape of the command is:

```sh
kubectl -n harbor exec harbor-database-0 -- pg_dump -U postgres registry > registry.sql
```

`registry` is the name of Harbor's main database. A restore reverses the steps: stop `core` and `jobservice`, load the dump, bring the components back. Test a restore on a copy before you need it.

## Upgrading the Compose installers

An installation made with the online or offline installer has no revisions to roll back to, so the backup is the only way back. The usual steps are:

1. Stop Harbor with `docker compose down` in the installer folder.
2. Back up the data volume (`data_volume` in `harbor.yml`) and the database.
3. Keep the old installer folder and `harbor.yml` as a copy.
4. Extract the new installer, convert the old `harbor.yml` to the new format with the `migrate` command of the new `goharbor/prepare` image (the upgrade page of the documentation gives the exact command for the release), and review the result.
5. Run `./prepare` and then `./install.sh` in the new folder, with the same options as before, for example `--with-trivy`.

The data volume is reused, so the new containers find the old data and `core` migrates the database as described above. To go back, stop the new containers, restore the backup and start the old installer folder.

## After any upgrade

Check the same things in both installation types: every component healthy in the health API, the expected version in the system information, a push and a pull, and a look at the logs of `core` and `jobservice` for repeated errors. Keep the backup until the new version has run through a full cycle of the jobs you depend on, such as garbage collection and replication.

You now know that a rollback is as safe as the data allows, and that the only complete way back is a backup you have tested. This closes the upgrade cycle: plan, back up, preview, apply, check, and roll back when needed.

## Common pitfalls

> [!WARNING]
> - **Rolling back across a migration.** Helm does not revert the database schema; restore the backup instead.
> - **An untested backup.** A dump that was never restored may be unusable.
> - **Forgetting the `secretKey`.** Passwords stored in the database cannot be decrypted without the key that encrypted them.
> - **Running `docker compose down -v`.** The `-v` option removes volumes and the data with them.
