#!/bin/bash
set -euox pipefail

# validate docs
./helm-docs
git diff --exit-code
