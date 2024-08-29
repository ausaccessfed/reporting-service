#!/bin/sh

set -e

# Let the startup probe know we're ready
echo "Creating /tmp/started"
touch /tmp/started

if [ "${DEBUG_CONTAINER-}" == "true" ]; then
  echo 'Debugging!'
  exec tail -f /dev/null
else
  echo 'Running!'
  exec bundle exec prometheus_exporter -p "${PORT:-9493}" -b 0.0.0.0
fi
