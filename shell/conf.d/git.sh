export GPG_TTY=$(tty)

alias g=git

alias t="g brc | sed -E 's/^(HS-[0-9]+)-.*$/\1/'"

ct() {
  local TICKET="$(t)"
  g cim "$TICKET $*"
}
