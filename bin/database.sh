#!/bin/bash

if [ "${DEBUG_CONTAINER-}" == "true" ]; then
  echo 'Debugging!'
  tail -f /dev/null
else
  echo "Preparing database..."
  bundle exec ${PREPARE_DB_COMMAND-rails db:prepare}
  if [ "${LOAD_DEVELOPMENT_DATA-}" == "true" ]; then
    bundle exec rails db:seed
  fi
fi
