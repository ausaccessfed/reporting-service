#!/bin/bash

set -e

if [ "$ENABLE_PROBES" != "false" ]; then
    cat /app/tmp/server.pid
fi
