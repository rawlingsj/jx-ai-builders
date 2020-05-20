#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

VERSION=$1

jx step create pr regex --regex '^(?m)\s+Image: \$INTERNAL_DOCKER_REGISTRY/nuxeo/builder-.*:(.*)$' --version "${VERSION}" \
  --files values.yaml \
  --repo https://github.com/nuxeo/jx-ai-env.git
