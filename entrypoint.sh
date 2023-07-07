#!/bin/sh -l

set -x

git_setup() {
  cat <<- EOF > $HOME/.netrc
		machine github.com
		login $GITHUB_ACTOR
		password $GITHUB_TOKEN
		machine api.github.com
		login $GITHUB_ACTOR
		password $GITHUB_TOKEN
EOF
  chmod 600 $HOME/.netrc

  git config --global user.email "$GITBOT_EMAIL"
  git config --global user.name "$GITHUB_ACTOR"
  git config --global --add safe.directory /github/workspace
}

git_cmd() {
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    echo $@
  else
    eval $@
  fi
}

git_setup

PR_BRANCH="auto-$INPUT_PR_BRANCH-$GITHUB_SHA"
MESSAGE=$(git log -1 $GITHUB_SHA | grep "AUTO" | wc -l)

if [[ $MESSAGE -gt 0 ]]; then
  echo "Autocommit, NO ACTION"
  exit 0
fi

PR_TITLE=$(git log -1 --format="%s" $GITHUB_SHA)

if expr index "$PR_TITLE" "#" > /dev/null; then
  PR_NUMBER=$(echo "$PR_TITLE" | sed 's/.*#\([0-9]\{1,\}\).*/\1/')
fi

git_cmd git remote update
git_cmd git fetch --all
git_cmd git checkout -b "${PR_BRANCH}" origin/"${INPUT_PR_BRANCH}"

if [ -n "$PR_NUMBER" ]; then
  echo "PR number found. Creating cherry pick PR."
  git_cmd gh pr diff --patch $PR_NUMBER | git am
else
  echo "PR number not found. Creating cherry pick PR for direct commit."
  git_cmd git cherry-pick "${GITHUB_SHA}"
fi

git_cmd git push -u origin "${PR_BRANCH}"
git_cmd hub pull-request -b "${INPUT_PR_BRANCH}" -h "${PR_BRANCH}" -l "${INPUT_PR_LABELS}" -a "${GITHUB_ACTOR}" -m "\"AUTO 🍒: ${PR_TITLE}\""