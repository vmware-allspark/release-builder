#!/bin/bash

# Copyright Istio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# https://github.com/istio/release-builder/blob/release-1.5/release/build.sh

WD=$(dirname "$0")
WD=$(cd "$WD"; pwd)

####### ALLSPARK BEGIN #######

source ${WD}/manifest.sh

####### ALLSPARK END #######

set -eux

ISTIO_ENVOY_BASE_URL="https://storage.googleapis.com/tsm-istio-build"

if [[ -n ${ISTIO_ENVOY_BASE_URL:-} ]]; then
  PROXY_OVERRIDE="proxyOverride: ${ISTIO_ENVOY_BASE_URL}"
fi

# We shouldn't push here right now, this is just which version to embed in the Helm charts
DOCKER_HUB=${DOCKER_HUB:-docker.io/istio}
VERSION="$(cat "${WD}/trigger-build")"

WORK_DIR="$(mktemp -d)/build"
mkdir -p "${WORK_DIR}"

MANIFEST=$(cat <<EOF
version: ${VERSION}
docker: ${DOCKER_HUB}
directory: ${WORK_DIR}
dependencies:
${DEPENDENCIES:-}
${PROXY_OVERRIDE:-}
EOF
)

# "Temporary" hacks
export PATH=${GOPATH}/bin:${PATH}

go run main.go build --manifest <(echo "${MANIFEST}")
go run main.go validate --release "${WORK_DIR}/out"
#go run main.go publish --release "${WORK_DIR}/out" --dockerhub "${DOCKER_HUB}" --dockertags "${VERSION}"