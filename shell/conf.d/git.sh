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
gm-help() {
  echo "Commit with style" >&2
  echo "" >&2
  echo "   gm <type> <scope> <message>" >&2
  echo "   # type(scope): message" >&2
  echo "" >&2
  echo "Type:  e.g. feat" >&2
  echo " - b fix (alias)" >&2
  echo " - c chore" >&2
  echo " - d doc" >&2
  echo " - f fix" >&2
  echo " - ft feat (feature)" >&2
  echo " - hf hotfix" >&2
  echo " - t test" >&2
  echo " - w wip" >&2
  echo "" >&2
  echo "Scope:  e.g. packages" >&2
  echo " - Use hyphen (-) for an explicit non-scoped commit" >&2
  echo "Message:  e.g. add new event types" >&2
}
gm-validate-type() {
  case "$1" in
    "chore" ) return 0 ;;
    "doc" ) return 0 ;;
    "fix" ) return 0 ;;
    "feat" ) return 0 ;;
    "hotfix" ) return 0 ;;
    "test" ) return 0 ;;
    "wip" ) return 0 ;;
    * )
      echo "Invalid type: $1" >&2
      return 1
    ;;
  esac
}
gm-validate-scope() {
  if [ "$1" = "wip" ]; then
    return 0
  fi
  if [ ! -z "$3" ]; then
    return 0
  fi
  if [ -z "$2" ]; then
    echo "Invalid empty commit scope" >&2
    return 1
  fi
  return 0
}
gm-validate-message() {
  if [ "$1" = "wip" ]; then
    return 0
  fi
  if [ -z "$3" ]; then
    echo "Invalid empty commit message" >&2
    return 1
  fi
  return 0
}
gm() {
  if [ -z "$1" ]; then
    gm-help
    return
  fi
  local TYPE="${@:1:1}"
  local SCOPE="${@:2:1}"
  local MESSAGE=()
  local FLAGS=()
  case "$TYPE" in
    "b" ) TYPE="fix" ;;
    "c" ) TYPE="chore" ;;
    "d" ) TYPE="doc" ;;
    "f" ) TYPE="fix" ;;
    "ft" ) TYPE="feat" ;;
    "hf" ) TYPE="hotfix" ;;
    "t" ) TYPE="test" ;;
    "w" ) TYPE="wip" ;;
  esac
  case "$SCOPE" in
    "-" ) SCOPE="" ;;
  esac
  for word in "${@:3}"; do
    case $word in
      "--" | "-" ) MESSAGE+=("$word") ;;
      "--"* | "-"* ) FLAGS+=("$word") ;;
      * ) MESSAGE+=("${word}") ;;
    esac
  done
  MESSAGE="${MESSAGE[*]}"
  gm-validate-type "$TYPE" "$SCOPE" "$MESSAGE" || return $?
  gm-validate-scope "$TYPE" "$SCOPE" "$MESSAGE" || return $?
  gm-validate-message "$TYPE" "$SCOPE" "$MESSAGE" || return $?
  local COMMIT_MSG="$TYPE"
  if [ ! -z "$SCOPE" ]; then
    COMMIT_MSG="$COMMIT_MSG($SCOPE)"
  fi
  COMMIT_MSG="$COMMIT_MSG: $MESSAGE"
  if [ "$DEBUG" = "1" ]; then
    echo "$ git commit $FLAGS -m "'"'"$COMMIT_MSG"'"' >&2
    return 2
  fi
  git commit $FLAGS -m "$COMMIT_MSG"
}

gm-old() {
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
  local FLAGS=()
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
      FLAGS+=("--no-verify")
      ;;
  esac

  local MSG=""
  for word in "${@:2}"; do
    case $word in
      "--"*) FLAGS+=("$word");;
      "-"*) FLAGS+=("$word");;
      *) MSG="${MSG}${word} ";;
    esac
  done
  MSG="${MSG%?}"

  if [ -z "$MSG" ]; then
    MSG="${DESC%?}"
  elif [ ! -z "${DESC}" ]; then
    MSG="${DESC} ${MSG}"
  fi

  if [[ "$(pwd)" != *"projects/web"* ]]; then
    if [ -z "$MSG" ]; then
      MSG="${EMOJI}"
    elif [ ! -z "${EMOJI}" ]; then
      MSG="${EMOJI} ${MSG}"
    fi
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
