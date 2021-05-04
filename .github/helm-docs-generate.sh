#!/bin/bash
set -euox pipefail

git config user.name "$TECHNICAL_USER"
git config user.email "$TECHNICAL_USER@users.noreply.github.com"

./helm-docs

READMES_CHANGED=$(git diff --name-only HEAD -- 'charts/**/README.md')

change_count=0
for README_CHANGED in ${READMES_CHANGED}; do
  git add ${README_CHANGED}
  ((++change_count))
done

if [ $change_count -gt 0 ]; then
  echo "Push ${change_count} readmes to ${BRANCH_NAME}"
  git commit -m "Automated README generation"
  git push "https://$TECHNICAL_USER:$TECHNICAL_USER_TOKEN@github.com/${GITHUB_REPOSITORY}.git"
fi
