你好！
很冒昧用这样的方式来和你沟通，如有打扰请忽略我的提交哈。我是光年实验室（gnlab.com）的HR，在招Golang开发工程师，我们是一个技术型团队，技术氛围非常好。全职和兼职都可以，不过最好是全职，工作地点杭州。
我们公司是做流量增长的，Golang负责开发SAAS平台的应用，我们做的很多应用是全新的，工作非常有挑战也很有意思，是国内很多大厂的顾问。
如果有兴趣的话加我微信：13515810775  ，也可以访问 https://gnlab.com/，联系客服转发给HR。
# cri-tools

CLI and validation tools for Kubelet Container Runtime Interface (CRI) .

[![Build Status](https://travis-ci.org/kubernetes-sigs/cri-tools.svg?branch=master)](https://travis-ci.org/kubernetes-sigs/cri-tools)
[![Go Report Card](https://goreportcard.com/badge/github.com/kubernetes-sigs/cri-tools)](https://goreportcard.com/report/github.com/kubernetes-sigs/cri-tools)

## What is the scope of this project?

cri-tools aims to provide a series of debugging and validation tools for Kubelet CRI, which includes:

- crictl: CLI for kubelet CRI.
- critest: validation test suites for kubelet CRI.

## What is not in scope for this project?

- Building a new kubelet container runtime based on CRI.
- Managing pods/containers for CRI-compatible runtimes by end-users, e.g. pods created by crictl may be removed automatically by kubelet because of non-exist on the kube-apiserver.

## Current Status

Version matrix:

| Kubernetes Version | cri-tools Version | cri-tools branch |
|--------------------|-------------------|------------------|
| 1.13.X             | v1.13.0           | master           |
| 1.12.X             | v1.12.0           | release-1.12     |
| 1.11.X             | v1.11.1           | release-1.11     |
| 1.10.X             | v1.0.0-beta.2     | release-1.10     |
| 1.9.X              | v1.0.0-alpha.1    | release-1.9      |
| 1.8.X              | v0.2              | release-1.8      |
| 1.7.X              | v0.1              | release-1.7      |

See the [roadmap](docs/roadmap.md) for information about current and future milestones.

## Install

### Install crictl

```sh
VERSION="v1.13.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz
```

### Install critest

```sh
VERSION="v1.13.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/critest-$VERSION-linux-amd64.tar.gz
sudo tar zxvf critest-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f critest-$VERSION-linux-amd64.tar.gz
```

## Documentation

- [CRI validation test suite](docs/validation.md)
- [CRI performance benchmarking](docs/benchmark.md)
- [CRI CLI](docs/crictl.md)

## Community, discussion, contribution, and support

Learn how to engage with the Kubernetes community on the [community page](http://kubernetes.io/community/).

You can reach the maintainers of this project at:

- Slack: #sig-node
- Mailing List: <https://groups.google.com/forum/#!forum/kubernetes-sig-node>

## Kubernetes Incubator

This is a [Kubernetes Incubator project](https://github.com/kubernetes/community/blob/master/incubator.md). The incubator team for the project is:

- Sponsor: Dawn Chen (@dchen1107)
- Champion: Yu-Ju Hong (@yujuhong)
- SIG: sig-node

## Contributing

Interested in contributing? Check out the [documentation](CONTRIBUTING.md).

## Code of conduct

Participation in the Kubernetes community is governed by the [Kubernetes Code of Conduct](code-of-conduct.md).
