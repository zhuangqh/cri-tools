#!/usr/bin/env bash

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -o errexit
set -o nounset
set -o pipefail

POUCH_VERSION="5e2c01d0"
POUCH_REPO=github.com/alibaba/pouch
WORKDIR="${GOPATH}/src/${POUCH_REPO}"

# pouch::check_version checks the command and the version.
pouch::check_version() {
  local has_installed version

  has_installed="$(command -v pouchd || echo false)"
  if [[ "${has_installed}" = "false" ]]; then
    echo false
    exit 0
  fi

  version="$(pouchd --version | cut -d " " -f3 | cut -d "," -f1)"
  if [[ "${POUCH_VERSION}" != "${version}" ]]; then
    echo false
    exit 0
  fi

  echo true
}

# pouch::install downloads repo and build.
pouch::install() {
  if [ ! -d "${WORKDIR}" ]; then
    mkdir -p "${WORKDIR}"
    cd "${WORKDIR}"
    git clone https://${POUCH_REPO} .
    git checkout ${POUCH_VERSION}
  fi

  cd "${WORKDIR}"
  git fetch --all
  git checkout ${POUCH_VERSION}

  make build
  TEST_FLAGS= BUILDTAGS="selinux seccomp apparmor" make build-daemon-integration
  sudo env "PATH=$PATH" make install
  cd -
}

main() {
  local has_installed

  has_installed="$(pouch::check_version)"
  if [[ "${has_installed}" = "true" ]]; then
    echo "pouch-${POUCH_VERSION} has been installed."
    exit 0
  fi

  echo ">>>>  install pouch-${POUCH_VERSION}  <<<<"
  pouch::install

  command -v pouchd > /dev/null
}

main "$@"
