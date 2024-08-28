## Information
Grafana running in a minimal OpenSUSE Docker Image

Using pre-built Grafana executable version from Grafana github project. Everything put into a minimal Container image built from an OpenSUSE tumbleweed image

## Run the image

You can run the image via Docker
```
docker run -dit ghcr.io/svenbeisiegel/grafana:11.1.4-r0-tumbleweed
```
## Configuration

A valid grafana.ini file must be mounted into the container.
```
-v /path/to/grafana.ini:/etc/grafana/grafana.ini
```
