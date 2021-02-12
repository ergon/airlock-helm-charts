#!/bin/bash
set -euox pipefail

# Write Error Message
echo -e "\033[0;31m ######## The helm-docs validation failed. ######## \033[0m" >&2
echo -e "\033[0;31m Make sure that the documentation has been updated. \033[0m" >&2

git config user.name "$TECHNICAL_USER"
git config user.email "$TECHNICAL_USER@users.noreply.github.com"

git fetch
git checkout  ${BRANCH_NAME}

./helm-docs

READMES_CHANGED=$(git diff --name-only HEAD -- 'charts/**/README.md')

for README_CHANGED in ${READMES_CHANGED}; do
  git add ${README_CHANGED}
done 

git commit -m "Automated README generation"
echo "Push to ${BRANCH_NAME}"
git push "https://$TECHNICAL_USER:$TECHNICAL_USER_TOKEN@github.com/${GITHUB_REPOSITORY}.git" ${BRANCH_NAME}

git checkout master

rm helm-docs
