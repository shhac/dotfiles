# Git Aliases
git config --global alias.f 'fetch'
git config --global alias.a 'add'
git config --global alias.ai 'add --patch'
git config --global alias.last 'log -1 --stat'
git config --global alias.cp 'cherry-pick'
git config --global alias.st 'status -sb'
git config --global alias.co 'checkout'
git config --global alias.cob 'checkout -b'
git config --global alias.col 'checkout @{-1}'
git config --global alias.com 'checkout master'
git config --global alias.cl 'clone'
git config --global alias.ci 'commit'
git config --global alias.cim 'commit -m'
git config --global alias.br 'branch'
git config --global alias.brr 'branch -r'
git config --global alias.brc 'rev-parse --abbrev-ref HEAD'
git config --global alias.unstage 'restore --staged'
git config --global alias.boom 'reset --hard HEAD'
git config --global alias.dc 'diff --cached'
git config --global alias.df '!git --no-pager diff --stat'
git config --global alias.lg 'log --graph --pretty=format:'"'"'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset'"'"' --abbrev-commit --date=relative'
git config --global alias.lga 'log --graph --pretty=format:'"'"'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset'"'"' --abbrev-commit --date=relative --all'
git config --global alias.pl 'pull'
git config --global alias.ps 'push'
git config --global alias.uncommit 'reset --soft HEAD^'
git config --global alias.likenew '!git clean -fdx && git reset HEAD --'
git config --global alias.forget 'checkout --'
git config --global alias.radd '!git rm -r --cached . && git add .'
git config --global alias.mm 'merge master'
git config --global alias.empty '!git cat-file -e e69de29bb2d1d6434b8b29ae775ad8c2e48c5391 || git hash-object -w --stdin < /dev/null; git update-index --add --cacheinfo 0644 e69de29bb2d1d6434b8b29ae775ad8c2e48c5391'

# git switch
git config --global alias.sw 'switch'
git config --global alias.swc 'switch -c'
git config --global alias.swm 'switch master'
git config --global alias.swl 'switch -'
# git switch + submodule updates
git config --global alias.swz '!f(){ git switch "$@" && git submodule update --init --recursive; }; f'
git config --global alias.swmz '!git switch master && git submodule update --init --recursive'
git config --global alias.swlz '!git switch - && git submodule update --init --recursive'


# History rewriting
git config --global alias.ri 'rebase -i'
git config --global alias.rim 'rebase -i master'
git config --global alias.ric 'rebase --continue'
git config --global alias.ria '!git rebase -i `git merge-base HEAD master`'
git config --global alias.rih '!f(){ git rebase -i "HEAD~$@"; }; f'
git config --global alias.commend 'commit --amend --no-edit'
git config --global alias.please 'push --force-with-lease'
git config --global alias.fix '!f(){ git commit --fixup "${1}" ${@:2}; git rebase -i "${1}~1" --autosquash --autostash; }; f'

# New Repos
git config --global alias.it '!f(){ git init; git commit -m "${1-Initial Commit}" --allow-empty; }; f'

# Merged branches
git config --global alias.br-merged '!f(){ git branch --merged ${1-master} | cut -c 3- | grep -v ${1-master}; }; f'
git config --global alias.brr-merged '!f(){ git branch -r --merged ${2-origin}/${1-master} | grep ${2-origin}/ | cut -c 3- | sed -e "s/^${2-origin}\/HEAD \-\> //" | grep -v ${2-origin}/${1-master} | cut -c $(echo "${2-origin}/." | awk '"'"'{print length}'"'"')-; }; f'

# Submodules
git config --global alias.sup 'submodule update --init --recursive'
git config --global alias.coz '!f(){ git checkout "$@" && git submodule update --init --recursive; }; f'
git config --global alias.colz '!git checkout @{-1} && git submodule update --init --recursive'
git config --global alias.comz '!git checkout master && git submodule update --init --recursive'
git config --global alias.plz '!git pull && git submodule update --init --recursive'
git config --global alias.clz 'clone --recursive'
git config --global alias.suff '!f(){ echo "Submodule Target Branch: ${1-master}"; git submodule update --init --recursive && echo "\n" && git submodule foreach "git checkout ${1-master} && git pull --ff-only && git submodule update --init --recursive; echo "";"; }; f'
git config --global alias.sucoz '!f() { git submodule foreach "rm -r ./*"; git checkout ${1-master}; git submodule update --init --recursive; git submodule foreach "git reset --hard HEAD"; }; f'
git config --global alias.sufe 'submodule foreach'

# Tig Aliases
git config --global alias.history '!git reflog --pretty=raw | tig --pretty=raw'
git config --global alias.bl '!tig blame --'
git config --global alias.file '!tig --'

# diff-so-fancy
git config --global alias.dsf '!f() { [ -z \"$GIT_PREFIX\" ] || cd \"$GIT_PREFIX\" && git diff --color \"$@\" | diff-so-fancy | less --tabs=4 -RFX; }; f'
git config --global alias.dsfc 'dsf --cached'
git config --global alias.compare 'dsf --no-index'

# Branch cleanup utilities
git config --global alias.merged-remote-view '!git branch -r --merged origin/master | grep origin | grep -v ">" | grep -v master | xargs -L1 | awk "{sub(/origin\//,\"\");print}"'
git config --global alias.merged-remote-clean '!git branch -r --merged origin/master | grep origin | grep -v ">" | grep -v master | sed "s/origin\///" | xargs -I {} git push origin --delete {}'
git config --global alias.deleted-remote-view '!git remote prune origin --dry-run'
git config --global alias.deleted-remote-clean '!git remote prune origin'
