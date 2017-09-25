# Git Aliases
git config --global alias.f 'fetch'
git config --global alias.a 'add'
git config --global alias.last 'log -1 --stat'
git config --global alias.cp 'cherry-pick'
git config --global alias.st 'status -sb'
git config --global alias.co 'checkout'
git config --global alias.cob 'checkout -b'
git config --global alias.col 'checkout @{-1}'
git config --global alias.com 'checkout master'
git config --global alias.cl 'clone'
git config --global alias.ci 'commit'
git config --global alias.cia 'commit -a'
git config --global alias.cim 'commit -m'
git config --global alias.ciam 'commit -am'
git config --global alias.br 'branch'
git config --global alias.brr 'branch -r'
git config --global alias.unstage 'reset HEAD --'
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
git config --global alias.up '!git checkout master && git fetch && git pull && git checkout @{-1} && git merge master'
git config --global alias.mm 'merge master'

# History rewriting
git config --global alias.ri 'rebase -i'
git config --global alias.rim 'rebase -i master'
git config --global alias.ric 'rebase --continue'
git config --global alias.ria '!git rebase -i `git merge-base HEAD master`'
git config --global alias.rih '!f(){ git rebase -i "HEAD~$@"; }; f'
git config --global alias.commend 'commit --amend --no-edit'
git config --global alias.please 'push --force-with-lease'

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

