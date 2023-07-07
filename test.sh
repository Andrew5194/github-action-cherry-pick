set -x

PR_TITLE='Merge pull request #7 from Andrew5194/testing-cherry-pick-action'
regex='Merge pull request #([0-9]+)'
if [[ $PR_TITLE =~ $regex ]]; then
  pr_number="${BASH_REMATCH[1]}"
  echo "PR Number: $pr_number"
else
  echo "PR Number not found"
fi