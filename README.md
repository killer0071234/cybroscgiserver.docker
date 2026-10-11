# cybroscgiserver.docker

Docker container for the CyBro SCGI server from the [Cybro Edge Toolkit](https://cybrotech.com/software/) by Cybrotech Ltd.

![workflow](https://github.com/killer0071234/cybroscgiserver.docker/actions/workflows/docker-publish.yml/badge.svg)

The SCGI server is used for communicating with CyBro-2 and CyBro-3 PLCs from Cybrotech Ltd.
The image also contains the data logger and MQTT client of the toolkit, which can be started as separate containers.

## Contains

- Python 3.12 on Alpine Linux, for linux/amd64, linux/arm64 and linux/arm/v7 (e.g. Raspberry Pi)
- Cybro Edge Toolkit (2026-10-09, `scgi_server` v3.4.0, `data_logger` v3.2.4, `mqtt_client` v1.0.4), downloaded from cybrotech.com during the build
- nginx, serving the SCGI server as plain HTTP on port 80
- example configuration files in [config/](config/)

`web_scada` from the toolkit is not included.

## Install and run

```sh
docker run -d --name cybroscgiserver -p 4000:4000/tcp -p 4080:80/tcp -p 8442:8442/udp killer007/cybroscgiserver:latest
```

All options (`-p`, `-v`, ...) must be placed **before** the image name; everything after the image name is passed to the container as a command.

Or with docker compose, see [docker-compose.yml](docker-compose.yml):

```sh
docker compose up -d
```

## Usage

For detailed usage and valid system tags check the manual in the toolkit zip file: <https://cybrotech.com/software/>

| Port | Description |
| ---- | ----------- |
| 80/tcp | HTTP via nginx, XML answer. Example: `http://[ip]:4080/?sys.server_uptime` |
| 4000/tcp | SCGI socket, XML answer. Example: `http://[ip]:4000/?sys.server_uptime` |
| 8442/udp | A-bus communication and push messages from the controllers |

Log messages are written to stdout, use `docker logs cybroscgiserver` to see them.

### Network

Autodetect of controllers uses UDP broadcasts, which do not leave the default docker bridge network. Either

- run the container with `--network host` (port mappings are not needed then), or
- add controllers with a static ip address to `config.ini` (`[c20000]` sections), or
- let the controllers send push messages to `[docker host ip]:8442`.

## Configuration

The configuration file can be found under [config/config.ini](config/config.ini). Mount your own file to `/usr/local/bin/scgi_server/config.ini`:

```sh
-v "./config/config.ini:/usr/local/bin/scgi_server/config.ini"
```

Changes in `config.ini` are detected automatically and the server restarts itself.

The example differs from the toolkit default in two settings:

- `[ETH] port = 8442`: a fixed port is needed so it can be published by docker
- `[DEBUGLOG] enabled = true, log_to_file = false`: errors are shown in `docker logs`

### Migrating a config.ini from v3.1.x

The old config file can still be used after adding two entries:

```ini
[SCGI]
server_address = localhost

[ALIAS]
```

The `[CAN]` and `[DATALOGGER]` sections are no longer used, the data logger is now a separate application (see below).

## Data logger and MQTT client

The same image runs the data logger or the MQTT client when the application name is passed as command:

```sh
docker run -d --network container:cybroscgiserver \
  -v "./config/config.ini:/usr/local/bin/scgi_server/config.ini" \
  -v "./config/data_logger.xml:/usr/local/bin/scgi_server/data_logger.xml" \
  killer007/cybroscgiserver:latest data_logger

docker run -d --network container:cybroscgiserver \
  -v "./config/config.ini:/usr/local/bin/scgi_server/config.ini" \
  killer007/cybroscgiserver:latest mqtt_client
```

`--network container:cybroscgiserver` lets them reach the SCGI server on `localhost` (`[SCGI] server_address`).

- data logger: stores variables into a MySQL database, configured in [config/data_logger.xml](config/data_logger.xml) and `[DBASE]` of `config.ini`. The database tables are created with `db_create.sql` from the toolkit zip file.
- MQTT client: configured in `[MQTT]`, `[PUBLISH]` and `[SUBSCRIBE]` of `config.ini`

### TLS

When `[SCGI] tls_enabled = true`, the certificate from the toolkit in `/usr/local/bin/scgi_server/tls/` is used. This key is publicly available, mount your own `private.crt` and `private.key` to that directory.
