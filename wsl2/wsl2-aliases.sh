# WSL2-specific aliases and functions

# Modern command replacements
if command -v exa >/dev/null 2>&1; then
    alias ls='exa'
    alias ll='exa -l'
    alias la='exa -la'
    alias lt='exa --tree'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
    alias less='bat'
fi

if command -v fd >/dev/null 2>&1; then
    alias find='fd'
fi

if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
fi

# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop $(docker ps -q)'
alias dclean='docker system prune -f'

# WSL2 system aliases
alias wsl-restart='cmd.exe /c "wsl --shutdown"'
alias wsl-ip='hostname -I | awk "{print \$1}"'
alias win-ip='cat /etc/resolv.conf | grep nameserver | awk "{print \$2}"'

# Quick directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Git aliases (complement to git/aliases.sh)
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# System information
alias sysinfo='echo "WSL2 System Information:" && uname -a && echo && df -h && echo && free -h'

# Network utilities
alias myip='curl -s ifconfig.me'
alias ports='netstat -tulanp'

# Development server shortcuts
alias serve-here='python3 -m http.server 8000'
alias serve-node='npx http-server -p 8000'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# Process management
alias psg='ps aux | grep'
alias topcpu='ps aux --sort=-%cpu | head'
alias topmem='ps aux --sort=-%mem | head'