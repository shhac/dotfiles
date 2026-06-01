# Linux-specific aliases and functions

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
elif command -v fdfind >/dev/null 2>&1; then
  alias find='fdfind'
  alias fd='fdfind'
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi

# System management aliases
if ! command -v exa >/dev/null 2>&1; then
  alias ll='ls -alF'
  alias la='ls -A'
fi
alias l='ls -CF'

# Quick directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# System information
alias sysinfo='echo "Linux System Information:" && uname -a && echo && df -h && echo && free -h'

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

# Package management shortcuts
if command -v apt >/dev/null 2>&1; then
  alias update='sudo apt update && sudo apt upgrade'
  alias install='sudo apt install'
  alias search='apt search'
elif command -v yum >/dev/null 2>&1; then
  alias update='sudo yum update'
  alias install='sudo yum install'
  alias search='yum search'
elif command -v dnf >/dev/null 2>&1; then
  alias update='sudo dnf update'
  alias install='sudo dnf install'
  alias search='dnf search'
elif command -v pacman >/dev/null 2>&1; then
  alias update='sudo pacman -Syu'
  alias install='sudo pacman -S'
  alias search='pacman -Ss'
fi
