#!/usr/bin/env bash
#
# Check container startup log for errors.
STARTUP_LOG=$(docker-compose logs "$SERVICE_NAME")

# Echo the log for travis.
echo $STARTUP_LOG

# If error strings found in startup, exit.
LOWER_STARTUP_LOG=${STARTUP_LOG,,}
if [[ $LOWER_STARTUP_LOG == *"error"* ]]; then
  echo "Error found in container startup."
  exit 1
fi
