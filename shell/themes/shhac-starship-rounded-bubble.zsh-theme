# vim:ft=zsh ts=2 sw=2 sts=2
#
# Starship Rounded Bubble Theme
# Rounded bubble with subtle background color and smooth edges
# Intelligently wraps to multiple lines when terminal is narrow
#
# Order: time → error/status → path → venv → node → git

# Powerline rounded separators
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  __shhac_theme_bubble_left=$'\ue0b6'   #
  __shhac_theme_bubble_right=$'\ue0b4'  #
}

# Helper: Open bubble
__shhac_theme_bubble_open() {
  echo -n "%{%k%}%{%F{236}%}$__shhac_theme_bubble_left%{%K{236}%}%{%F{default}%}"
}

# Helper: Close bubble
__shhac_theme_bubble_close() {
  echo -n " %{%k%}%{%F{236}%}$__shhac_theme_bubble_right%{%f%}"
}

### Prompt components (return both colored and plain text)

# Time
prompt_time() {
  local plain=" $(date '+%H:%M:%S')"
  local colored="%{%F{cyan}%}$plain%{%f%}"
  echo "$colored|$plain"
}

# Status: errors, root, background jobs
prompt_status() {
  local -a symbols
  local -a plain_symbols

  if [[ $RETVAL -ne 0 ]]; then
    if [[ $RETVAL -gt 128 ]]; then
      local realret="$(($RETVAL-128))"
      symbols+="%{%F{red}%}✘→$realret%{%f%}"
      plain_symbols+="✘→$realret"
    else
      symbols+="%{%F{red}%}✘ $RETVAL%{%f%}"
      plain_symbols+="✘ $RETVAL"
    fi
  fi

  if [[ $UID -eq 0 ]]; then
    symbols+="%{%F{yellow}%}⚡%{%f%}"
    plain_symbols+="⚡"
  fi

  if [[ $(jobs -l | wc -l) -gt 0 ]]; then
    symbols+="%{%F{cyan}%}⚙%{%f%}"
    plain_symbols+="⚙"
  fi

  if [[ ${#symbols} -gt 0 ]]; then
    local colored=" ${(j: :)symbols}"
    local plain=" ${(j: :)plain_symbols}"
    echo "$colored|$plain"
  else
    echo "|"
  fi
}

# Context: user@hostname (only shown when relevant)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    local plain=" %n@%m"
    local colored=" %{%F{default}%}%(!.%{%F{yellow}%}.)%n@%m%{%f%}"
    echo "$colored|$plain"
  else
    echo "|"
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

  local plain=" $result"
  local colored=" %{%F{blue}%}$result%{%f%}"
  echo "$colored|$plain"
}

# Virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    local plain=" $(basename $virtualenv_path)"
    local colored=" %{%F{cyan}%} $(basename $virtualenv_path)%{%f%}"
    echo "$colored|$plain"
  else
    echo "|"
  fi
}

# Node version
prompt_node() {
  local nv
  if [ -x "$(command -v node)" ]; then
    nv="$(node --version | sed -E 's/^v([0-9]+\.[0-9]+).*$/\1/')"
    local plain=" ⬢ $nv"
    local colored=" %{%F{magenta}%}⬢ $nv%{%f%}"
    echo "$colored|$plain"
  else
    echo "|"
  fi
}

# Git
prompt_git() {
  (( $+commands[git] )) || { echo "|"; return; }
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    echo "|"
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

    local plain_vcs="${vcs_info_msg_0_%% }"
    local plain=" 󰊢 ${branch}${plain_vcs}${mode}"
    local colored=" ${git_color}󰊢 ${branch}${vcs_info_msg_0_%% }${mode}%{%f%}"
    echo "$colored|$plain"
  else
    echo "|"
  fi
}

## Main prompt
build_prompt() {
  RETVAL=$?

  # Capture components as "colored|plain"
  local time_data="$(prompt_time)"
  local status_data="$(prompt_status)"
  local context_data="$(prompt_context)"
  local path_data="$(prompt_dir)"
  local venv_data="$(prompt_virtualenv)"
  local node_data="$(prompt_node)"
  local git_data="$(prompt_git)"

  # Extract colored and plain versions
  local time_colored="${time_data%%|*}"
  local time_plain="${time_data##*|}"

  local status_colored="${status_data%%|*}"
  local status_plain="${status_data##*|}"

  local context_colored="${context_data%%|*}"
  local context_plain="${context_data##*|}"

  local path_colored="${path_data%%|*}"
  local path_plain="${path_data##*|}"

  local venv_colored="${venv_data%%|*}"
  local venv_plain="${venv_data##*|}"

  local node_colored="${node_data%%|*}"
  local node_plain="${node_data##*|}"

  local git_colored="${git_data%%|*}"
  local git_plain="${git_data##*|}"

  # Calculate FULL line length including all content (visible characters only)
  # Include: ╭─ (2) + bubble_left (1) + all content + bubble_right (1) = 4 extra chars
  local full_line_plain="╭─${time_plain}${status_plain}${context_plain}${path_plain}${venv_plain}${node_plain}${git_plain} "
  local full_line_length=${#full_line_plain}
  local bubble_chars=2  # bubble left + bubble right
  local buffer=8
  local needed_width=$((full_line_length + bubble_chars + buffer))

  # DEBUG: Uncomment to see calculation
  # echo "DEBUG: full_line_length=$full_line_length, bubble_chars=$bubble_chars, buffer=$buffer, needed=$needed_width, COLUMNS=$COLUMNS" >&2

  # Start prompt
  echo -n "%{%F{242}%}╭─"
  __shhac_theme_bubble_open
  echo -n "${time_colored}${status_colored}${context_colored}${path_colored}"

  # Check if we need line wrap
  if [[ $needed_width -gt $COLUMNS ]]; then
    __shhac_theme_bubble_close
    echo -n "\n%{%F{242}%}├─"
    __shhac_theme_bubble_open
  fi

  # Continue with remaining content
  echo -n "${venv_colored}${node_colored}${git_colored}"
  __shhac_theme_bubble_close
}

PROMPT='%{%f%b%k%}$(build_prompt)
%{%F{242}%}╰─%{%F{default}%}❯ '
