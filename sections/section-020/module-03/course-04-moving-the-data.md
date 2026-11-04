# Moving The Data

Settings are the easy half of a migration. The other half is the data: the database and the image blobs. This part gives the order of a migration that can be repeated and rolled back.

## The order

1. **Freeze writes.** Stop pushes and scheduled jobs in the old installation, or set a project to read-only, so the copy is consistent.
2. **Back up.** Take a database dump and a copy of the registry storage, and save `secretKey` and the certificate.
3. **Prepare the target.** Install the chart with the same Harbor version as the old installation, with the same `secretKey`, so that the database schema matches.
4. **Restore the database.** Load the dump into the new database with `psql`.
5. **Copy the blobs.** Copy the registry storage into the new volume or bucket.
6. **Switch the address.** Point the host name at the new installation and set `externalURL` to it.
7. **Check.** Pull an old image by digest, push a new one, and read the health API.
8. **Upgrade last.** Move to a newer Harbor version only after the migrated installation works.

## Same version first

The database dump carries the schema of the old version. Installing a newer version first and loading an old dump into it does not run the migrations in the right order. Match the version, restore, check, then upgrade as a separate step.

## Check by digest

After the copy, compare an image by its digest on both sides:

<!-- astrona:playground:renew -->

```sh
ws regctl image digest harbor.localtest.me:8443/library/example:1.0
```

Replace the name with an image that exists in your installation. The digest must be equal on the old and the new Harbor; a different digest means the blob data differs.

## Common pitfalls

> [!WARNING]
> - **Migrating and upgrading in one step.** If it fails, you cannot tell which change broke it.
> - **Copying blobs and database at different times.** Records and blobs will not match.
> - **Switching the address before the check.** Clients push to an installation that is not verified.
> - **Deleting the old installation at once.** Keep it, stopped, until the new one has run for a while.
