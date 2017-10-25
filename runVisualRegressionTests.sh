#!/usr/bin/env bash
set -e

if [ -f ./tests/backstop/backstop.json ]; then
  echo "Running Regression Tests in /tests/backstop..."
  docker run --rm -v $(pwd)/tests/backstop:/src docksal/backstopjs test
else
  echo "No Visual Regression Tests in /tests/backstop."
fi
