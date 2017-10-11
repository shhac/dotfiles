current_branch=$(git branch | grep '*' | awk '{print $2}')
if [ "$current_branch" = "master" ]; then
  git branch -vv |
  awk '/: gone]/{print $1}'
else
  echo "ERROR: Please switch to master frist, current branch is $current_branch"
fi

