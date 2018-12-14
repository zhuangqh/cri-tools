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

set -euo pipefail

CNI_VERSION=v0.7

# keep the first one only
GOPATH="${GOPATH%%:*}"


# cni::install installs cni plugins.
cni::install() {
  local pkg workdir

  # for multiple GOPATHs, keep the first one only
  pkg="github.com/containernetworking/plugins"
  workdir="${GOPATH}/src/${pkg}"

  echo ">>>>  install cni-${CNI_VERSION}  <<<<"

  # downloads github.com/containernetworking/plugins
  if [ ! -d "${workdir}" ]; then
    mkdir -p "${workdir}"
    cd "${workdir}"
    git clone https://${pkg}.git .
  fi
  cd "${workdir}"
  git fetch --all
  git checkout "${CNI_VERSION}"

  # build and copy into /opt/cni/bin
  "${workdir}"/build.sh
  mkdir -p /etc/cni/net.d /opt/cni/bin
  cp "${workdir}"/bin/* /opt/cni/bin

  # setup the config
  sh -c 'cat >/etc/cni/net.d/10-mynet.conflist <<-EOF
{
    "cniVersion": "0.3.1",
    "name": "mynet",
    "plugins": [
        {
            "type": "bridge",
            "bridge": "cni0",
            "isGateway": true,
            "ipMasq": true,
            "ipam": {
                "type": "host-local",
                "subnet": "10.30.0.0/16",
                "routes": [
                    { "dst": "0.0.0.0/0"   }
                ]
            }
        },
        {
            "type": "portmap",
            "capabilities": {"portMappings": true},
            "snat": true
        }
    ]
}
EOF'

  sh -c 'cat >/etc/cni/net.d/99-loopback.conf <<-EOF
{
    "cniVersion": "0.3.1",
    "type": "loopback"
}
EOF'

  echo
}

main() {
  cni::install
}

main "$@"
