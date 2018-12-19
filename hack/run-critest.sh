#!/bin/bash

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

# Run critest with pouch.

set -o errexit
set -o nounset
set -o pipefail

# CRI_SKIP skips the test to skip.
DEFAULT_CRI_SKIP="should error on create with wrong options"
CRI_SKIP="${CRI_SKIP:-"${DEFAULT_CRI_SKIP}"}"

# CRI_FOCUS focuses the test to run.
# With the CRI manager completes its function, we may need to expand this field.
CRI_FOCUS=${CRI_FOCUS:-}

POUCH_SOCK="/var/run/pouchcri.sock"

# tmplog_dir stores the background job log data
tmplog_dir="$(mktemp -d /tmp/integration-daemon-cri-testing-XXXXX)"
pouchd_log="${tmplog_dir}/pouchd.log"
trap 'rm -rf /tmp/integration-daemon-cri-testing-*' EXIT

# Run e2e test cases
critest::run_e2e() {
    cri_runtime=$1
    if [[ "${cri_runtime}" == "v1alpha1" ]]; then
      critest --runtime-endpoint=${POUCH_SOCK} \
        --focus="${CRI_FOCUS}" --ginkgo-flags="--skip=\"${CRI_SKIP}\"" validation
    else
      critest --runtime-endpoint=${POUCH_SOCK} \
        --ginkgo.focus="${CRI_FOCUS}" --ginkgo.skip="${CRI_SKIP}"
    fi

    code=$?

    if [[ "${code}" != "0" ]]; then
        echo "failed to pass cri e2e cases!"
        echo "there is daemon logs..."
        cat "${pouchd_log}"
        exit ${code}
    fi
}

main() {
    cri_runtime=$1
    critest::run_e2e "${cri_runtime}"
}

main "$@"
