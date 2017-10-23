#!/usr/bin/env bash
#
# Build the repository docker images and bring it up.
set -e

docker-compose build
docker images --all
docker-compose up -d
