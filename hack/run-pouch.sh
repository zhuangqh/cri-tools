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

POUCH_REPO=github.com/alibaba/pouch
WORKDIR="${GOPATH}/src/${POUCH_REPO}"

# pouch::check_daemon_listening checks if daemon is listening
pouch::check_daemon_listening() {
  local has_listened pouchd_sock
  pouchd_sock="/var/run/pouchd.sock"

  has_listened="$(netstat -lx | grep ${pouchd_sock} || echo false)"
  if [[ "${has_listened}" = "false" ]]; then
    echo false
    exit 0
  fi

  echo true
}

# pouch::check_cri_listening checks if daemon with cri is listening
pouch::check_cri_listening() {
  local has_listened pouchcri_sock
  pouchcri_sock="/var/run/pouchcri.sock"

  has_listened="$(netstat -lx | grep ${pouchcri_sock} || echo false)"
  if [[ "${has_listened}" = "false" ]]; then
    echo false
    exit 0
  fi

  echo true
}

# pouchd::install_dependencies downloads and installs dependent packages
pouch::install_dependencies() {
  cd "${WORKDIR}"
  make download-dependencies
  cd -
}

# pouch::stop_dockerd makes sure dockerd is not running
pouch::stop_dockerd() {
  if [[ X"" != X"$(pidof docker)" ]]; then
    # need to avoid conflict between dockerd and pouchd
    systemctl stop docker
  fi
}

# pouch:run starts pouch daemon with cri enabled
pouch::run() {
  local cri_runtime tmplog_dir pouchd_log sandbox_img flags

  cri_runtime=$1
  tmplog_dir="$(mktemp -d /tmp/integration-daemon-cri-testing-XXXXX)"
  pouchd_log="${tmplog_dir}/pouchd.log"

  # daemon cri integration coverage profile
  coverage_profile="${WORKDIR}/coverage/integration_daemon_cri_${cri_runtime}_profile.out"
  rm -rf "${coverage_profile}"

  sandbox_img="gcr.io/google_containers/pause-amd64:3.0"
  flags=" -test.coverprofile=${coverage_profile} DEVEL"
  flags="${flags} --enable-cri --cri-version ${cri_runtime} --sandbox-image=${sandbox_img}"

  ${WORKDIR}/bin/pouchd-integration ${flags} > $pouchd_log 2>&1 &

  # Wait a while for pouch daemon starting
  sleep 10
}

main() {
  local cri_runtime pouchd_has_listened pouchcri_has_listened
  cri_runtime=$1

  pouch::install_dependencies

  pouchd_has_listened="$(pouch::check_daemon_listening)"
  pouchcri_has_listened="$(pouch::check_cri_listening)"

  if [[ "${pouchd_has_listened}" = "true" ]] && [[ "${pouchcri_has_listened}" = "true" ]]; then
    echo "pouchd and pouchcri have been listened."
    exit 0
  fi

  pouch::stop_dockerd
  pouch::run "${cri_runtime}"

  pouchcri_has_listened="$(pouch::check_cri_listening)"

  if [[ "${pouchcri_has_listened}" = "false" ]]; then
    echo "pouchcri has not been listened: $(netstat -lx)"
    exit 1
  fi

  exit 0
}

main "$@"
