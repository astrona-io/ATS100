# Backing Up Harbor

A restore is only as good as the backup behind it. Harbor's data lives in several places, and a backup that misses one of them restores a Harbor that starts but cannot pull. This part makes a database dump and lists everything else that belongs in a backup.

## Dump the database

PostgreSQL ships `pg_dump`, which writes the database as SQL. The Harbor database is named `registry`, and the database user is `postgres`:

<!-- astrona:playground:renew -->

```sh
kubectl -n harbor exec harbor-database-0 -- pg_dump -U postgres registry > harbor-registry.sql
wc -l harbor-registry.sql
```

The first command writes the dump to a file on your machine; the second counts its lines. A dump taken while Harbor runs is consistent for the database itself, but it does not match blobs pushed a moment later.

## What a complete backup holds

| Item | Why |
| --- | --- |
| Database dump | Users, projects, artifact records and policies |
| Registry storage | The blobs; without them records point at nothing |
| Helm values file | The settings that created this installation |
| Secrets such as `secretKey` and the certificate | Encrypted fields in the database cannot be read without the same key |
| Job service logs (optional) | History of jobs, nice to keep |

The `secretKey` matters most after the database: Harbor encrypts stored credentials, such as registry endpoints, with it. A restored database with a new key cannot decrypt them.

## Keep the backup in step

Take the database dump and the storage copy close together, and note the time. After a restore, run garbage collection carefully: blobs newer than the dump have no record and would be removed. Test a restore in a separate cluster before you need one.

## Common pitfalls

> [!WARNING]
> - **Backing up only the database.** Without the registry storage nothing can be pulled.
> - **Losing the `secretKey`.** Encrypted settings become unreadable.
> - **Storing the dump next to the cluster.** Keep it on separate storage.
> - **Never testing a restore.** An untested backup is a guess.
