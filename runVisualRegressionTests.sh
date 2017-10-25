#!/usr/bin/env bash
set -e

if [ -f ./tests/backstop/backstop.json ]; then
  echo "Running Regression Tests in /tests/backstop..."

  echo "Pulling Upstream Image"
  git pull docksal/backstopjs

  echo "Running Tests"
  docker run --rm -v $(pwd)/tests/backstop:/src docksal/backstopjs test

  TEST_RETURN_CODE=$?
  if [ $TEST_RETURN_CODE != 0 ]; then
    echo "Visual Regression Tests Report Failures. Exiting."
    exit 1
  fi

  echo "Visual Regression Tests Passed."
else
  echo "No Visual Regression Tests in /tests/backstop."
fi
