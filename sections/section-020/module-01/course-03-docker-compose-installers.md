# The Docker Compose Installers And harbor.yml

Not every Harbor runs on Kubernetes. Many teams run it on one virtual machine with Docker Compose, and the Harbor project ships installers for exactly that. The settings are the same ones you met in the Helm values, under different names. This part maps them, so you can read and fix a `harbor.yml` as easily as a values file. This page has no hands-on steps: the course environments run Harbor on Kubernetes only.

## Online and offline installers

Harbor publishes two installers for each release on its GitHub releases page, for example `harbor-online-installer-v2.15.4.tgz` and `harbor-offline-installer-v2.15.4.tgz`. Both contain the same scripts and a template configuration file:

| Installer | What it contains | When to use it |
| --- | --- | --- |
| Online | The scripts and `harbor.yml.tmpl`; images are pulled from Docker Hub during the install | A machine with internet access |
| Offline | The same, plus every Harbor image in one archive | A machine without internet access |

The target machine needs Docker Engine and Docker Compose. The installer runs every Harbor component as a container on that machine, with the same names you know from Kubernetes: `nginx`, `harbor-portal`, `harbor-core`, `registry`, `registryctl`, `harbor-jobservice`, `harbor-db`, `redis` and `trivy-adapter`.

## harbor.yml

You copy `harbor.yml.tmpl` to `harbor.yml` and edit it before the first install. The settings below are the ones that decide how Harbor is reached and where it keeps data:

```yaml
hostname: harbor.inventory.example.com

http:
  port: 80

https:
  port: 443
  certificate: /etc/harbor/certs/harbor.crt
  private_key: /etc/harbor/certs/harbor.key

harbor_admin_password: Change-me-1

database:
  password: Change-me-db-1

data_volume: /data

trivy:
  ignore_unfixed: false
  skip_update: false
```

The installer reads this file once, when it generates the containers' configuration. Each setting has a counterpart in the Helm values:

| `harbor.yml` | `harbor-helm` value | What it decides |
| --- | --- | --- |
| `hostname` (plus `https.port`) | `externalURL` | The address in the token realm and the portal's commands |
| `https.certificate`, `https.private_key` | `expose.tls.certSource: secret` and the Secret | The certificate `nginx` presents; the files must exist on the machine |
| `harbor_admin_password` | `harborAdminPassword` | The first password of `admin`, used only at the first start |
| `data_volume` | `persistence` | Where registry blobs, the database and logs live on disk |
| `external_url` (optional) | `externalURL` | The URL clients use when a proxy in front of Harbor changes it |

`hostname` must be the name clients use, not `localhost` or `127.0.0.1`, for the same reason `externalURL` must be: it becomes the token realm. If a reverse proxy in front of Harbor uses another host or port, set `external_url` to that address.

## prepare and install.sh

Two scripts turn `harbor.yml` into running containers. `./prepare` reads `harbor.yml` and writes the configuration of every component and the `docker-compose.yml` file. `./install.sh` runs `prepare`, loads the images when the installer is offline, and starts everything with Docker Compose. Scanning with Trivy is optional and must be asked for:

```bash
sudo ./install.sh --with-trivy
```

A change to `harbor.yml` later follows the same order: stop Harbor with `docker compose down`, edit `harbor.yml`, run `sudo ./prepare --with-trivy`, and start it again with `docker compose up -d`. Without `prepare`, the containers keep the old configuration, which is the Docker Compose form of upgrading a Helm release without new values.

Older guides mention `--with-notary` and `--with-chartmuseum`. Harbor 2.15 has neither: Notary was replaced by Cosign signatures, and Helm charts are stored as OCI artifacts.

You can now read a `harbor.yml` and map each setting to the Helm value that does the same job. Whichever installer you use, the two settings to check first stay the same: the address clients use, and the certificate presented on it.

## Common pitfalls

> [!WARNING]
> - **`hostname: localhost`.** The token realm then points every client at itself. Use the name clients use.
> - **Editing `harbor.yml` without running `prepare`.** The containers keep their old configuration until `prepare` writes a new one.
> - **Forgetting `--with-trivy`.** Harbor starts without a scanner, and scanning is missing from the portal.
> - **Using the online installer without internet access.** The image pulls fail; use the offline installer.
