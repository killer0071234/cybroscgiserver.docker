# syntax=docker/dockerfile:1.7
ARG TOOLKIT_URL=https://cybrotech.com/wp-content/uploads/CybroEdgeToolkit.zip
# The download URL is not versioned: update this checksum (and the version label) when Cybrotech publishes a new release
ARG TOOLKIT_SHA256=7aa7efc99392033ca9e5e69cc6fb9cf07aa279f91176be3fb1eb758d4ecf22b5

FROM alpine:3.22 AS download
ARG TOOLKIT_URL
ARG TOOLKIT_SHA256
ADD --checksum=sha256:${TOOLKIT_SHA256} ${TOOLKIT_URL} /tmp/toolkit.zip
RUN unzip -q /tmp/toolkit.zip -d /tmp/toolkit

FROM python:3.12-alpine

LABEL org.opencontainers.image.authors="Daniel Gangl <killer007@gmx.at>"
LABEL org.opencontainers.image.source="https://github.com/killer0071234/cybroscgiserver.docker"
LABEL CYBRO_EDGE_TOOLKIT_VERSION="2026-10-09"
LABEL SCGI_SERVER_VERSION="3.4.0"

ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache nginx

# runtime dependencies of scgi_server, data_logger and mqtt_client (web_scada and Windows-only WMI are not included)
RUN apk add --no-cache --virtual .build-deps gcc musl-dev linux-headers \
 && pip install --no-cache-dir watchdog==4.0.0 psutil==5.9.8 paho-mqtt==2.0.0 aiomysql==0.2.0 \
 && apk del .build-deps

WORKDIR /usr/local/bin/scgi_server

COPY --from=download /tmp/toolkit/app/lib ./lib
COPY --from=download /tmp/toolkit/app/scgi_server ./scgi_server
COPY --from=download /tmp/toolkit/app/data_logger ./data_logger
COPY --from=download /tmp/toolkit/app/mqtt_client ./mqtt_client
COPY --from=download /tmp/toolkit/app/tls ./tls
COPY config/ ./
COPY nginx/nginx.conf /etc/nginx/http.d/default.conf
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["scgi_server"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null "http://localhost/?sys.server_uptime" || exit 1

EXPOSE 80/tcp
EXPOSE 4000/tcp
EXPOSE 8442/udp
