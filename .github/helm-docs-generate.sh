#!/bin/bash
set -euox pipefail

# Write Error Message
echo -e "\033[0;31m ######## The helm-docs validation failed. ######## \033[0m" >&2
echo -e "\033[0;31m Make sure that the documentation has been updated. \033[0m" >&2

git config user.name "$GITHUB_USER"
git config user.email "$GITHUB_USER@users.noreply.github.com"
          
./helm-docs

git checkout ${BRANCH_NAME}
git add charts/microgateway/README.md
git commit -m "Automated README generation"
echo "Push to ${BRANCH_NAME}"
git push "https://$GITHUB_USER:$GITHUB_TOKEN@github.com/${GITHUB_REPOSITORY} ${BRANCH_NAME}

rm helm-docs
