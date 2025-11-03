# vim:ft=zsh ts=2 sw=2 sts=2
#
# Rainbow Road Theme
# Colorful powerline segments with vibrant colors
#
# Order: time → error/status → path → venv → node → git

### Segment drawing
CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='black';;
esac

# Special Powerline characters
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components

# Time (purple)
prompt_time() {
  prompt_segment 093 231 "%D{%H:%M}"
}

# Status: errors, root, background jobs (red/yellow/cyan on black)
prompt_status() {
  local -a symbols

  if [[ $RETVAL -ne 0 ]]; then
    symbols+="%{%F{red}%}✘ $RETVAL"
  fi
  [[ $UID -eq 0 ]] && symbols+=" %{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+=" %{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

# Context: user@hostname (only shown when relevant)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)%n@%m"
  fi
}

# Dir: current working directory (blue)
prompt_dir() {
  local path='%(4~|%-1~/…/%2~|%~)'
  local expanded="${(%)path}"

  # Truncate each directory component to 16 chars
  local -a parts
  parts=("${(@s:/:)expanded}")
  local result=""

  for part in $parts; do
    if [[ ${#part} -gt 16 ]]; then
      part="${part:0:15}…"
    fi
    if [[ -n $result ]]; then
      result="${result}/${part}"
    else
      result="$part"
    fi
  done

  prompt_segment 033 231 "$result"
}

# Virtualenv (cyan)
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment 051 016 "🐍 $(basename $virtualenv_path)"
  fi
}

# Node version (magenta/pink)
prompt_node() {
  local nv
  if [ -x "$(command -v node)" ]; then
    nv="$(node --version | sed -E 's/^v([0-9]+\.[0-9]+).*$/\1/')"
    prompt_segment 201 231 "⬢ $nv"
  fi
}

# Git (green/yellow based on status)
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'
  }
  local ref dirty mode repo_path

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

    if [[ -n $dirty ]]; then
      prompt_segment 220 016
    else
      prompt_segment 040 016
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    local branch="${ref/refs\/heads\//$PL_BRANCH_CHAR }"
    if [[ ${#branch} -gt 17 ]]; then
      branch="${branch:0:16}…"
    fi
    echo -n "${branch}${vcs_info_msg_0_%% }${mode}"
  fi
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_time
  prompt_status
  prompt_context
  prompt_dir
  prompt_virtualenv
  prompt_node
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt)
› '
