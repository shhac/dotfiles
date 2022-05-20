export GPG_TTY=$(tty)

alias g=git

git-is-git() {
  if [ -d ".git" ]; then
    return 0
  fi
  git rev-parse --git-dir > /dev/null 2>&1 && return 0
  return 1
}

git-branch-to-ticket() {
  echo "$1" | sed -E 's/^(refs\/heads\/)?([A-Z]{2,}-[0-9]+)-.*$|^.*$/\2/'
}

git-ticket() {
  git-is-git || return 1
  local BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  local TICKET="$(git-branch-to-ticket $BRANCH)"
  if [ ! -z "$TICKET" ]; then
    echo "$TICKET"
    return 0
  fi
  
  local DOTGIT="$(git rev-parse --git-dir)"
  if [ -d "$DOTGIT/rebase-merge" ]; then
    BRANCH="$(cat "$DOTGIT/rebase-merge/head-name")"
  elif [ -d "$DOTGIT/rebase-apply" ]; then
    BRANCH="$(cat "$DOTGIT/rebase-apply/head-name")"
  fi

  TICKET="$(git-branch-to-ticket $BRANCH)"
  if [ ! -z "$TICKET" ]; then
    echo "$TICKET"
    return 0
  fi
  return 1
}


alias t="git-ticket"

unalias gm
gm() {
  if [ -z "$1" ]; then
    echo "Commit with style:" >&2
    echo "- 🎉 a add feature" >&2
    echo "- 🐛 b bug" >&2
    echo "- ⬆️ bump" >&2
    echo "- ⚡️ c change u update" >&2
    echo "- 📝 d doc document" >&2
    echo "- 💼 dep depend dependency" >&2
    echo "- 🚑 f fix" >&2
    echo "- 💄 i im improve ui" >&2
    echo "- 🚨 l li lint" >&2
    echo "- 🚚 m mv move" >&2
    echo "- 🔥 r rm remove del delete" >&2
    echo "- ♻️ ref refactor" >&2
    echo "- ✅ t test" >&2
    echo "- 🚧 w wip" >&2
    return
  fi

  local TICKET=""
  # local TICKET="$(t)"
  # if [[ "$TICKET" =~ ^[A-Z]+-[0-9]+$ ]]; then
  #   TICKET="$TICKET"
  # else
  #   TICKET=""
  # fi

  local EMOJI=""
  local DESC=""
  local FLAGS=""
  case "$1" in
    "a"|"add"|"feature" )
      EMOJI="🎉"
      DESC="ADD:"
      ;;
    "b"|"bug" )
      EMOJI="🐛"
      DESC="BUG:"
      ;;
    "bump" )
      EMOJI="⬆️"
      DESC="BUMP:"
      ;;
    "c"|"change"|"u"|"update" )
      EMOJI="️⚡️"
      DESC="UPDATE:"
      ;;
    "d"|"doc"|"document" )
      EMOJI="📝"
      DESC="DOC:"
      ;;
    "dep"|"depend"|"dependency" )
      EMOJI="💼"
      DESC="DEPENDENCY:"
      ;;
    "f"|"fix" )
      EMOJI="🚑"
      DESC="FIX:"
      ;;
    "i"|"im"|"improve"|"ui" )
      EMOJI="💄"
      DESC="IMPROVE:"
      ;;
    "l"|"li"|"lint" )
      EMOJI="🚨"
      DESC="LINT:"
      ;;
    "m"|"mv"|"move" )
      EMOJI="🚚"
      DESC="MOVE:"
      ;;
    "r"|"rm"|"remove"|"del"|"delete" )
      EMOJI="🔥"
      DESC="REMOVE:"
      ;;
    "ref"|"refactor" )
      EMOJI="♻️"
      DESC="REFACTOR:"
      ;;
    "t"|"test" )
      EMOJI="✅"
      DESC="TEST:"
      ;;
    "w"|"wip" )
      EMOJI="🚧"
      DESC="WIP:"
      FLAGS="--no-verify"
      ;;
  esac

  local MSG=""
  for word in "${@:2}"; do
    case $word in
      "--"*) if [ -z "$FLAGS"]; then; FLAGS="$word"; else; FLAGS="$FLAGS $word"; fi;;
      *) MSG="${MSG}${word} ";
    esac
  done
  MSG="${MSG%?}"

  if [ -z "$MSG" ]; then
    MSG="${DESC%?}"
  elif [ ! -z "${DESC}" ]; then
    MSG="${DESC} ${MSG}"
  fi

  if [ -z "$MSG" ]; then
    MSG="${EMOJI}"
  elif [ ! -z "${EMOJI}" ]; then
    MSG="${EMOJI} ${MSG}"
  fi

  if [ -z "$MSG" ]; then
    MSG="${TICKET}"
  elif [ ! -z "${TICKET}" ]; then
    MSG="${TICKET} ${MSG}"
  fi

  echo git commit $FLAGS -m "$MSG"
  git commit $FLAGS -m "$MSG"
}

ct() {
  local TICKET="$(t)"
  if [[ "$TICKET" =~ ^[A-Z]+-[0-9]+$ ]]; then
    g cim "$TICKET $*"
  else
    g cim "$*"
  fi
}
