#!/bin/sh

set -e

if [ "$ENABLE_PROBES" != "false" ]; then
  curl --fail "http://localhost:${PORT:-9493}/ping"
fi
