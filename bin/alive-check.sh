#!/bin/bash

set -e

if [ "$ENABLE_PROBES" != "false" ]; then
    curl --fail -k https://localhost:$PORT/health
fi
