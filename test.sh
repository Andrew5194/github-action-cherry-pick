set -x

string="Merge pull request #7 from Andrew5194/testing-cherry-pick-action"
pr_number=$(echo "$string" | grep -oP '(?<=Merge pull request #)[0-9]+')
echo "PR Number: $pr_number"