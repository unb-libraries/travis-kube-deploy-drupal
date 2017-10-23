#!/usr/bin/env bash
set -e

# Update docker-compose.yml to map Drupal to local port 80 for testing purposes.
sed -i 's|.*:80\"|      - "80:80"|g' docker-compose.yml
cat docker-compose.yml
