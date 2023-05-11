#!/bin/bash

set -e

if [ "$ENABLE_PROBES" != "false" ]; then
    curl --fail http://localhost:$PORT/health
fi
