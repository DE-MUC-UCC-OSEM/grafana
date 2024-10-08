#!/bin/bash

set -e

if [ "$EXTERNAL_SERVER_ADDR" ]; then
  sed -i -e "s/__EXTERNAL_SERVER_ADDR__/$EXTERNAL_SERVER_ADDR/" /etc/grafana/grafana.ini
fi

if [ "$INTERNAL_SERVER_ADDR" ]; then
  sed -i -e "s/__INTERNAL_SERVER_ADDR__/$INTERNAL_SERVER_ADDR/" /etc/grafana/grafana.ini
fi

exec "$@"
