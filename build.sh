#!/bin/bash
# build.sh — builds and tests the alpine-flash script.
#
# Usage:
#   ./build.sh                      # local build, VERSION=latest
#   VERSION=3.21.0 ./build.sh       # versioned build, VERSION=3.21.0
#
# Environment:
#   VERSION       Release version tag (default: empty = latest)
set -e

VERSION="${VERSION:-}"

# Shellcheck
docker run --rm -v "$(pwd):/mnt" -w /mnt koalaman/shellcheck -s bash flash

# Inject version into flash script
if [ -n "${VERSION}" ]; then
  sed -i "s/dirty/${VERSION}/g" flash
else
  sed -i "s/dirty/latest/g" flash
fi

echo "Version: $(./flash --version)"

# Run tests
TMP_DIR=$(mktemp -d)
docker build -t flash .
docker run --privileged -v "$(pwd):/code" -v "${TMP_DIR}:/tmp" -e CIRCLE_TAG flash npm test
rm -rf "${TMP_DIR}"

