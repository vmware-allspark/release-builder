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

WD=$(dirname "$0")
WD=$(cd "$WD"; pwd)

set -eux

# gcloud auth activate-service-account --key-file="${GOOGLE_APPLICATION_CREDENTIALS}"

# Temporary hack to get around some gcloud credential issues
# mkdir ~/.docker
# cp "${DOCKER_CONFIG}/config.json" ~/.docker/
# export DOCKER_CONFIG=~/.docker
# gcloud auth configure-docker -q

# PRERELEASE_DOCKER_HUB=${PRERELEASE_DOCKER_HUB:-gcr.io/istio-prerelease-testing}
# GCS_BUCKET=${GCS_BUCKET:-istio-prerelease/prerelease}

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
${DEPENDENCIES:-$(cat <<EOD
  istio:
    git: https://github.com/vmware-allspark/istio
    branch: build-1.4.7
  cni:
    git: https://github.com/vmware-allspark/cni
    auto: deps
  operator:
    git: https://github.com/vmware-allspark/operator
    auto: modules
  api:
    git: https://github.com/vmware-allspark/api
    auto: modules
  proxy:
    git: https://github.com/vmware-allspark/proxy
    auto: deps
  pkg:
    git: https://github.com/vmware-allspark/pkg
    auto: modules
  client-go:
    git: https://github.com/vmware-allspark/client-go
    branch: build-1.4.7
  gogo-genproto:
    git: https://github.com/vmware-allspark/gogo-genproto
    branch: build-1.4.7
  test-infra:
    git: https://github.com/vmware-allspark/test-infra
    branch: build-1.4.7
  tools:
    git: https://github.com/vmware-allspark/tools
    branch: build-1.4.7
  installer:
    git: https://github.com/vmware-allspark/installer
    branch: build-1.4.7
EOD
)}
${PROXY_OVERRIDE:-}
EOF
)

# "Temporary" hacks
export PATH=${GOPATH}/bin:${PATH}

go run main.go build --manifest <(echo "${MANIFEST}")
go run main.go validate --release "${WORK_DIR}/out"
go run main.go publish --release "${WORK_DIR}/out" --dockerhub "${DOCKER_HUB}" --dockertags "${VERSION}"
