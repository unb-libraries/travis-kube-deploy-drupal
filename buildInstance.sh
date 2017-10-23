#!/usr/bin/env bash
#
# Build the repository docker images and bring it up.
set -e

docker-compose build --tag $SERVICE_NAME:latest
docker-compose up -d
