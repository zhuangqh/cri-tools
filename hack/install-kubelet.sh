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

set -o errexit
set -o nounset
set -o pipefail

# Install kubelet
! go get -d k8s.io/kubernetes
cd $GOPATH/src/k8s.io/kubernetes
if [ ${TRAVIS_BRANCH:-"master"} != "master" ]; then
  # We can do this because cri-tools have the same branch name with kubernetes.
  if [ ${TRAVIS_BRANCH} == "tools-dev" ]; then
      # make sure branch name is consistent with kubernetes.
      TRAVIS_BRANCH="release-1.11"
  fi
  git checkout "${TRAVIS_BRANCH}"
fi
make WHAT='cmd/kubelet'
sudo cp _output/bin/kubelet /usr/local/bin

