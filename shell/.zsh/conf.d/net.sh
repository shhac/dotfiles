alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

if [[ "$(uname)" == "Darwin" ]]; then
  alias localip="ipconfig getifaddr en0"
else
  alias localip="hostname -I | awk '{print \$1}'"
fi

alias listip="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

port() {
  lsof -i "TCP:${1}"
}

