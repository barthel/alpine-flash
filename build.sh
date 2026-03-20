#!/bin/bash
# build.sh — builds and tests the alpine-flash script.
#
# Usage:
#   ./build.sh                           # local build
#   VERSION=3.21.0 ./build.sh            # versioned build
#   VERSION=3.21.0 PUSH=true ./build.sh  # versioned build + push to ghcr.io
#
# Environment:
#   VERSION       Release version tag (default: empty = latest)
#   PUSH          Set to "true" to push to GitHub Container Registry
#   GITHUB_USER   GitHub username (default: barthel)
set -e

VERSION="${VERSION:-}"
GITHUB_USER="${GITHUB_USER:-barthel}"
DIST_IMAGE="ghcr.io/${GITHUB_USER}/alpine-flash"

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

if [ "${PUSH:-false}" = "true" ]; then
  IMG_VERSION="${VERSION:-latest}"
  docker build -f Dockerfile.dist --tag "${DIST_IMAGE}:${IMG_VERSION}" .
  docker push "${DIST_IMAGE}:${IMG_VERSION}"

  if [ -n "${VERSION}" ]; then
    MAJOR="${VERSION%%.*}"
    MINOR="${VERSION%.*}"
    PRE=""
    if [[ "${VERSION}" = *"rc"* ]]; then PRE="true"; fi
    if [ -z "${PRE}" ]; then
      for extra_tag in "${MINOR}" "${MAJOR}" latest stable; do
        docker tag "${DIST_IMAGE}:${IMG_VERSION}" "${DIST_IMAGE}:${extra_tag}"
        docker push "${DIST_IMAGE}:${extra_tag}"
      done
    fi
  fi
fi
