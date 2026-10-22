# Section 020: Installing Harbor With Helm And TLS

Most Harbor problems after an installation come from two settings: the address Harbor believes clients use, and the certificate it presents. Both are set once, at install time, and both break every push when they are wrong. This section installs and configures Harbor the way it runs on Kubernetes, with the `harbor-helm` chart, and then shows how the Docker Compose installers set the same things in `harbor.yml`.

**Topic covered:** Installing Harbor

## What you will learn

- The `harbor-helm` values that matter first: `expose`, `externalURL`, `persistence` and `harborAdminPassword`.
- Why `externalURL` must match the address clients use, and how a wrong value breaks the token step of every push.
- Reading and changing an installation with `helm get values` and `helm upgrade`.
- The three TLS certificate sources (`auto`, `secret`, `none`) and how clients learn to trust Harbor's certificate authority.
- The online and offline installers, `harbor.yml`, `./prepare` and `./install.sh`.

## The learning path

Work through the module in order. It has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The landing page starts the module's playground.

### 1. Install And Configure Harbor With harbor-helm

The playground holds Harbor 2.15.4 with the project `inventory`, which already holds the podinfo image.

1. The harbor-helm Values That Matter, followed by the lab **Fix The External URL Of A Helm Install**
2. TLS Certificates And Trust
3. The Docker Compose Installers And harbor.yml
4. Summary

## Section capstone: Serve Harbor With Your Own Certificate

The capstone moves Harbor from the certificate the chart generated to one signed by the team's own certificate authority. Someone started the change and left it half done. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-020/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-100-capstone-020
```
