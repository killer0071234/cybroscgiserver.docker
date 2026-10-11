#!/bin/sh
set -e

case "$1" in
  scgi_server)
    nginx
    exec python scgi_server/start.py ;;
  data_logger|mqtt_client)
    exec python "$1/start.py" ;;
  *)
    exec "$@" ;;
esac
