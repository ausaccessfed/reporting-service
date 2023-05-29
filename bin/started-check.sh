#!/bin/bash

set -e

if [ "$ENABLE_PROBES" != "false" ]; then
    cat /app/tmp/pids/server.pid
fi
