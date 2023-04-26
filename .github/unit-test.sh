#!/bin/bash
set -euox pipefail

# install unittest helm plugin
helm plugin install --version v0.2.11 https://github.com/quintush/helm-unittest

#run unittest
helm unittest -3 charts/microgateway
