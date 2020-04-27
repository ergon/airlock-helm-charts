#!/bin/bash
set -euo pipefail

# Write Error Message
echo -e "\033[0;31m ######## The helm-docs validation failed. ######## \033[0m" >&2
echo -e "\033[0;31m Make sure that the documentation has been updated. \033[0m" >&2

git config user.name "$GITHUB_ACTOR"
git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
          
./helm-docs

READMES_CHANGED=$(git diff --name-only HEAD -- 'charts/**/README.md')

git checkout  ${BRANCH_NAME}
for README_CHANGED in ${READMES_CHANGED}; do
  git add ${README_CHANGED}
done 

git commit -m "Automated README generation"
echo "Push to ${BRANCH_NAME}"
git push "https://$GITHUB_ACTOR:$CR_TOKEN@github.com/libuweber/microgateway.git" ${BRANCH_NAME}

rm helm-docs
