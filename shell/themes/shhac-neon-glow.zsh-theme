# vim:ft=zsh ts=2 sw=2 sts=2
#
# Neon Glow Theme for Oh My Zsh
# ==============================
#
# A vibrant zsh theme with decorative brackets and connecting lines (╶┤ ├╶).
# Displays time, status, path, virtualenv, node version, and git information
# in a clean, neon-styled format.
#
# Configuration
# -------------
# Add these to your .zshrc BEFORE loading Oh My Zsh to customize the theme:
#
# Component Visibility (hide specific components):
#   export SHHAC_THEME_SHOW_TIME=false       # Hide time component
#   export SHHAC_THEME_SHOW_STATUS=false     # Hide error/root/jobs indicators
#   export SHHAC_THEME_SHOW_CONTEXT=false    # Hide user@hostname
#   export SHHAC_THEME_SHOW_PATH=false       # Hide current directory path
#   export SHHAC_THEME_SHOW_VENV=false       # Hide Python virtualenv
#   export SHHAC_THEME_SHOW_NODE=false       # Hide Node.js version
#   export SHHAC_THEME_SHOW_GIT=false        # Hide git information
#
# Font Settings:
#   export SHHAC_THEME_USE_POWERLINE=false   # Use ASCII fallback (g:, n:, v:)
#                                            # Default: true (assumes Nerd Font available)
#
# Requirements
# ------------
# - zsh 5.0+
# - git 2.18+ (recommended for full git features)
# - Nerd Font or Powerline-patched font (recommended, fallback available)
#
# Features
# --------
# - Neon-styled decorative brackets (╶┤ ├╶) connecting components
# - Git ahead/behind tracking (↑N ↓N)
# - Signal-decoded error codes (✘→2 for SIGINT)
# - Configurable component visibility
# - ASCII fallback for non-Powerline terminals
# - Optimized git status with single git command
#
# Display Order: time → error/status → path → venv → node → git
#

# User Configuration: Control component visibility
# Set to false in your .zshrc before theme loads to hide components
: ${SHHAC_THEME_SHOW_TIME:=true}
: ${SHHAC_THEME_SHOW_STATUS:=true}
: ${SHHAC_THEME_SHOW_CONTEXT:=true}
: ${SHHAC_THEME_SHOW_PATH:=true}
: ${SHHAC_THEME_SHOW_VENV:=true}
: ${SHHAC_THEME_SHOW_NODE:=true}
: ${SHHAC_THEME_SHOW_GIT:=true}

# User-configurable Powerline/Nerd Font support
# Set SHHAC_THEME_USE_POWERLINE=false in your .zshrc to disable
() {
  if [[ "${SHHAC_THEME_USE_POWERLINE:-true}" == "false" ]]; then
    typeset -g __shhac_theme_use_powerline=0
    typeset -g __shhac_theme_git_icon='g:'
    typeset -g __shhac_theme_node_icon='n:'
    typeset -g __shhac_theme_venv_icon='v:'
  else
    typeset -g __shhac_theme_use_powerline=1
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    typeset -g __shhac_theme_git_icon=$'\ue0a0'  #
    typeset -g __shhac_theme_node_icon='⬢'
    typeset -g __shhac_theme_venv_icon='🐍'
  fi
}

# Initialize git/vcs_info settings once at theme load
() {
  setopt promptsubst
  autoload -Uz vcs_info

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' get-revision true
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' stagedstr '✚'
  zstyle ':vcs_info:*' unstagedstr '●'
  zstyle ':vcs_info:*' formats ' %u%c'
  zstyle ':vcs_info:*' actionformats ' %u%c'

  # Cache command existence
  typeset -g __shhac_has_git
  (( $+commands[git] )) && __shhac_has_git=1 || __shhac_has_git=0
}

### Prompt components

# Time
prompt_time() {
  [[ "$SHHAC_THEME_SHOW_TIME" != "true" ]] && return
  local time_fmt="%D{%H:%M:%S}"
  local time_str="${(%)time_fmt}"
  echo -n "%{%F{cyan}%}$time_str"
}

# Status: errors, root, background jobs
prompt_status() {
  [[ "$SHHAC_THEME_SHOW_STATUS" != "true" ]] && return
  local -a symbols

  if [[ $RETVAL -ne 0 ]]; then
    if [[ $RETVAL -gt 128 ]]; then
      local realret="$(($RETVAL-128))"
      symbols+="%{%F{red}%}✘→$realret"
    else
      symbols+="%{%F{red}%}✘ $RETVAL"
    fi
  fi

  [[ $UID -eq 0 ]] && symbols+=" %{%F{yellow}%}⚡"
  [[ ${#jobtexts} -gt 0 ]] && symbols+=" %{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && echo -n " %{%F{242}%}╶┤%{%F{default}%}$symbols %{%F{242}%}├╶"
}

# Context: user@hostname (only shown when relevant)
prompt_context() {
  [[ "$SHHAC_THEME_SHOW_CONTEXT" != "true" ]] && return
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    echo -n " %{%F{242}%}╶┤ %{%F{default}%}%(!.%{%F{yellow}%}.)%n@%m %{%F{242}%}├╶"
  fi
}

# Dir: current working directory
prompt_dir() {
  [[ "$SHHAC_THEME_SHOW_PATH" != "true" ]] && return
  local path='%(4~|%-1~/…/%2~|%~)'
  local expanded="${(%)path}"

  # Truncate each directory component to 24 chars
  local -a parts
  parts=("${(@s:/:)expanded}")
  local result=""

  for part in $parts; do
    if [[ ${#part} -gt 24 ]]; then
      part="${part:0:23}…"
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
  [[ "$SHHAC_THEME_SHOW_VENV" != "true" ]] && return
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    local venv_name="${virtualenv_path:t}"
    echo -n " %{%F{242}%}╶┤ %{%F{cyan}%}$__shhac_theme_venv_icon $venv_name %{%F{242}%}├╶"
  fi
}

# Node version
prompt_node() {
  [[ "$SHHAC_THEME_SHOW_NODE" != "true" ]] && return
  if command -v node >/dev/null 2>&1; then
    local nv
    nv="$(node --version 2>/dev/null)" || return

    # Extract major.minor version using native zsh parameter expansion
    nv="${nv#v}"              # Remove leading 'v'
    local major="${nv%%.*}"   # Get major version
    local rest="${nv#*.}"     # Remove major and first dot
    local minor="${rest%%.*}" # Get minor version
    nv="${major}.${minor}"    # Combine major.minor

    echo -n " %{%F{242}%}╶┤ %{%F{magenta}%}$__shhac_theme_node_icon $nv %{%F{242}%}├╶"
  fi
}

# Git - Optimized with single git status call
prompt_git() {
  [[ "$SHHAC_THEME_SHOW_GIT" != "true" ]] && return
  (( __shhac_has_git )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi

  # Single git status call with comprehensive output
  local status_output
  status_output=$(git status --porcelain=v2 --branch 2>/dev/null)
  [[ -z $status_output ]] && return

  # Parse status output
  local branch_name=""
  local has_staged=0
  local has_unstaged=0
  local is_detached=0
  local ahead=0
  local behind=0
  local has_upstream=0

  while IFS= read -r line; do
    case $line in
      "# branch.head "*)
        branch_name="${line#\# branch.head }"
        [[ $branch_name == "(detached)" ]] && is_detached=1
        ;;
      "# branch.ab "*)
        has_upstream=1
        local ab="${line#\# branch.ab }"
        ahead="${ab% *}"
        behind="${ab#* }"
        ;;
      "1 "* | "2 "*)
        # Ordinary changed entries (XY submodule mH mI mW hH hI path)
        local xy="${line:2:2}"
        [[ $xy[1] != "." ]] && has_staged=1
        [[ $xy[2] != "." ]] && has_unstaged=1
        ;;
      "? "*)
        # Untracked files
        [[ "${DISABLE_UNTRACKED_FILES_DIRTY:-}" != "true" ]] && has_unstaged=1
        ;;
    esac
  done <<< "$status_output"

  # Handle detached HEAD - get short SHA
  if [[ $is_detached -eq 1 ]]; then
    branch_name="➦ $(git rev-parse --short HEAD 2>/dev/null)"
  fi

  # Check for special modes
  local mode=""
  local repo_path=$(git rev-parse --git-dir 2>/dev/null)
  if [[ -n $repo_path ]]; then
    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi
  fi

  # Determine color based on dirty status
  local git_color
  if [[ $has_staged -eq 1 || $has_unstaged -eq 1 ]]; then
    git_color="%{%F{yellow}%}"
  else
    git_color="%{%F{green}%}"
  fi

  # Build indicators with new format: change indicator (±/+/●) followed by tracking indicators
  local indicators=""
  if [[ $has_staged -eq 1 && $has_unstaged -eq 1 ]]; then
    indicators="±"
  elif [[ $has_staged -eq 1 ]]; then
    indicators="+"
  elif [[ $has_unstaged -eq 1 ]]; then
    indicators="●"
  fi

  if [[ $has_upstream -eq 0 && $is_detached -eq 0 ]]; then
    indicators+=" ⚠"
  else
    [[ $ahead -gt 0 ]] && indicators+=" ↑$ahead"
    [[ $behind -gt 0 ]] && indicators+=" ↓$behind"
  fi

  [[ -n $indicators ]] && indicators=" $indicators"

  # Format branch name with icon
  local branch="$__shhac_theme_git_icon ${branch_name}"
  if [[ ${#branch} -gt 30 ]]; then
    branch="${branch:0:29}…"
  fi

  echo -n " %{%F{242}%}╶┤ ${git_color}${branch}${indicators}${mode} %{%F{242}%}├╶"
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
