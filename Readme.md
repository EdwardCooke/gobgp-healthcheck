# GOBGP-HEALTHCHECK
## Purpose
This is a simple Docker image that contains pre-compiled `gobgp` binaries and allows for health checks to control it.

When building the image it will pull the last released binaries from GitHub.

## Design
The project is broken into 5 primary pieces.

1. `startup.sh`, this script starts the container, it starts the `configurator` in the background, waits a second to make sure it's still running then starts the `gobgpd` daemon. This is the entrypoint to the docker image. You probably won't need to replace this.

1. `configurator.sh`, this script kicks off the `initializer` script, waits for it to finish and then passes control to the `healthcheck` script. You probably won't need to replace this either.

1. `initializer.sh`, this script is an opinionated way of configuring the `gobgpd` daemon. If you have a more complicated setup, you may want to replace this script with whatever suits your needs.

1. `healthcheck-*.sh`, these included healthchecks show how you can use a simple `curl` or `dig` command as a healthcheck to announce or withdraw a route.
  * The healtchecks should be an infinite loop without a `set -e` in it.

1. `monitor.sh`, watches the pid from `configurator.sh` and if it exits it will kill the container.

## Usage
The following options can be specified, `-u` is specific to health check so is not displayed in the help output

```text
--configurator <CONFIGURATOR SCRIPT> (defaults to ./configurator.sh)
--local-ip <LOCAL IP ADDRESS> (required)
--local-as <OUR AUTONOMOUS SYSTEM ID> (required)
--neighbor-ip <NEIGHBOR IP ADDRESS> (required)
--listen-port <LISTENING PORT> (defaults to 179)
--initializer <INITIALIZER SCRIPT> (defaults to ./initializer.sh)
--healtcheck <HEALTHCHECK SCRIPT> (required)
```

For `healthcheck-curl.sh`, `--healthcheck ./healthcheck-curl.sh`
```text
--url <URL> the URL to curl against for the healthcheck (required)
```

For `healthcheck-dig.sh`, `--healthcheck ./healthcheck-dig.sh`
```
--hostname <HOSTNAME to lookup> (required)
```

## Remarks
You can add your own healthcheck by mounting it into the container and setting the `--healthcheck` parameter to the path of your health check script.

The container runs as as the `nobody` user with a UID of `65534`.

This is based on the `alpine` image with `curl`, `bash`, `jq` and `bind-tools` installed.