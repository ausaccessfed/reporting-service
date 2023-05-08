#!/bin/bash

set -e
set -u

# Let the startup probe know we're ready
echo "Creating /tmp/started"
touch /tmp/started

if [ "${PREPARE_DB-}" != "" ]; then
  . bin/database.sh
fi

if [ "${TMPDIR-}" != "" ]; then
  mkdir $TMPDIR
fi

if [ "${DEBUG_CONTAINER-}" == "true" ]; then
  echo 'Debugging!'
  exec tail -f /dev/null
else
  echo "Running! exec $*"
  exec $*
fi
