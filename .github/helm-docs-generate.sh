#!/bin/bash
set -euox pipefail

git config user.name "$TECHNICAL_USER"
git config user.email "$TECHNICAL_USER@users.noreply.github.com"
git fetch
git checkout ${BRANCH_NAME}


# workaround: do not run build for auto-generated readmes. (github workflow ignore-paths does not work in this case)
changed_file=$(git diff-tree --no-commit-id --name-only -r ${{ github.event.before }} ${{github.event.after}})
file_count=$(git diff-tree --no-commit-id --name-only -r ${{ github.event.before }} ${{github.event.after}} | wc -l )
if [[$changed_file == 'charts/microgateway/README.md' && $file_count == 1]]
then
  echo ::set-output name=continue::false
  exit 0
else
  echo ::set-output name=continue::true
fi

make

READMES_CHANGED=$(git diff --name-only HEAD -- 'charts/**/README.md')

change_count=0
for README_CHANGED in ${READMES_CHANGED}; do
  git add ${README_CHANGED}
  ((++change_count))
done

if [ $change_count -gt 0 ]; then
  echo "Push ${change_count} readmes to ${BRANCH_NAME}"
  git commit -m "Automated README generation"
  git push "https://$TECHNICAL_USER:$TECHNICAL_USER_TOKEN@github.com/${GITHUB_REPOSITORY}.git" ${BRANCH_NAME}
fi
