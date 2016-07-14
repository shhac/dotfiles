git remote prune origin && 
git branch -r --merged origin/master | 
grep origin | 
grep -v '>' | 
grep -v master | 
xargs -L1 | 
awk '{sub(/origin\//,"");print}' | 
xargs git push origin --delete

