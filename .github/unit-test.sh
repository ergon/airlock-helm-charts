#!/bin/bash
set -euox pipefail

# install unittest helm plugin
helm plugin install https://github.com/quintush/helm-unittest

#run unittest
helm unittest charts/microgateway
