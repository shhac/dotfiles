# vim:ft=zsh ts=2 sw=2 sts=2
#
# Neon Glow Theme
# Vibrant theme with decorative brackets and lines
#
# Order: time → error/status → path → venv → node → git

### Prompt components

# Time
prompt_time() {
  echo -n "%{%F{cyan}%}%*"
}

# Status: errors, root, background jobs
prompt_status() {
  local -a symbols

  if [[ $RETVAL -ne 0 ]]; then
    symbols+="%{%F{red}%}✘ $RETVAL"
  fi
  [[ $UID -eq 0 ]] && symbols+=" %{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+=" %{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && echo -n " %{%F{242}%}╶┤%{%F{default}%}$symbols %{%F{242}%}├╶"
}

# Context: user@hostname (only shown when relevant)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    echo -n " %{%F{242}%}╶┤ %{%F{default}%}%(!.%{%F{yellow}%}.)%n@%m %{%F{242}%}├╶"
  fi
}

# Dir: current working directory
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

  echo -n " %{%F{242}%}╶┤ %{%F{blue}%}$result %{%F{242}%}├╶"
}

# Virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    echo -n " %{%F{242}%}╶┤ %{%F{cyan}%}🐍 $(basename $virtualenv_path) %{%F{242}%}├╶"
  fi
}

# Node version
prompt_node() {
  local nv
  if [ -x "$(command -v node)" ]; then
    nv="$(node --version | sed -E 's/^v([0-9]+\.[0-9]+).*$/\1/')"
    echo -n " %{%F{242}%}╶┤ %{%F{magenta}%}⬢ $nv %{%F{242}%}├╶"
  fi
}

# Git
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
  local ref dirty mode repo_path git_color

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

    if [[ -n $dirty ]]; then
      git_color="%{%F{yellow}%}"
    else
      git_color="%{%F{green}%}"
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
    echo -n " %{%F{242}%}╶┤ ${git_color}${branch}${vcs_info_msg_0_%% }${mode} %{%F{242}%}├╶"
  fi
}

## Main prompt
build_prompt() {
  RETVAL=$?
  echo -n "%{%F{242}%}╭─╸"
  prompt_time
  prompt_status
  prompt_context
  prompt_dir
  prompt_virtualenv
  prompt_node
  prompt_git
  echo -n "%{%F{242}%}╴"
}

PROMPT='%{%f%b%k%}$(build_prompt)
%{%F{242}%}╰─%{%F{default}%}❯ '
