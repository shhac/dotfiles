# vim:ft=zsh ts=2 sw=2 sts=2
#
# Starship Rounded Bubble Theme for Oh My Zsh
# ============================================
#
# A modern zsh theme with speech-bubble style prompt, rounded Powerline edges,
# and intelligent line wrapping. Displays time, status, path, virtualenv, node
# version, and git information in a clean, information-dense format.
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
#   export SHHAC_THEME_USE_POWERLINE=false   # Use ASCII fallback ([ ], g:, n:, v:)
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
# - Rounded bubble design with background color
# - Intelligent wrapping when terminal is narrow
# - Git ahead/behind tracking (↑N ↓N)
# - Signal-decoded error codes (✘→2 for SIGINT)
# - Configurable component visibility
# - ASCII fallback for non-Powerline terminals
#
# Display Order: time → error/status → path → venv → node → git
#

# Powerline rounded separators
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  __shhac_theme_bubble_left=$'\ue0b6'   #
  __shhac_theme_bubble_right=$'\ue0b4'  #
}

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
    __shhac_theme_bubble_left='['
    __shhac_theme_bubble_right=']'
    typeset -g __shhac_theme_git_icon='g:'
    typeset -g __shhac_theme_node_icon='n:'
    typeset -g __shhac_theme_venv_icon='v:'
  else
    typeset -g __shhac_theme_use_powerline=1
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    __shhac_theme_bubble_left=$'\ue0b6'
    __shhac_theme_bubble_right=$'\ue0b4'
    typeset -g __shhac_theme_git_icon='󰊢'
    typeset -g __shhac_theme_node_icon='⬢'
    typeset -g __shhac_theme_venv_icon=''
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
  typeset -g __shhac_has_git __shhac_has_node
  (( $+commands[git] )) && __shhac_has_git=1 || __shhac_has_git=0
  (( $+commands[node] )) && __shhac_has_node=1 || __shhac_has_node=0
}

# Initialize component output storage arrays once at theme load
typeset -gA __shhac_starship_component_colored
typeset -gA __shhac_starship_component_plain

# Configuration: Define bubble components and their order
typeset -ga PROMPT_BUBBLE_1=(time status context path)
typeset -ga PROMPT_BUBBLE_2=(venv node git)

# Configuration: Map component names to functions
typeset -gA PROMPT_COMPONENT_FUNCS=(
  time      __shhac_starship_prompt_time
  status    __shhac_starship_prompt_status
  context   __shhac_starship_prompt_context
  path      __shhac_starship_prompt_dir
  venv      __shhac_starship_prompt_virtualenv
  node      __shhac_starship_prompt_node
  git       __shhac_starship_prompt_git
)

# Helper: Open bubble
__shhac_theme_bubble_open() {
  echo -n "%{%k%}%{%F{236}%}$__shhac_theme_bubble_left%{%K{236}%}%{%F{default}%}"
}

# Helper: Close bubble
__shhac_theme_bubble_close() {
  echo -n " %{%k%}%{%F{236}%}$__shhac_theme_bubble_right%{%f%}"
}

# Helper: Standardized component output setter
# Sets both colored and plain output in associative arrays
# Usage: __shhac_starship_set_component_output component_name colored_text plain_text
__shhac_starship_set_component_output() {
  local component=$1
  local colored=$2
  local plain=$3

  __shhac_starship_component_colored[$component]=$colored
  __shhac_starship_component_plain[$component]=$plain
}

### Prompt components (use helper to set output)

# Time
__shhac_starship_prompt_time() {
  [[ "$SHHAC_THEME_SHOW_TIME" != "true" ]] && { __shhac_starship_set_component_output time "" ""; return; }
  local time_fmt="%D{%H:%M:%S}"
  local time_str="${(%)time_fmt}"
  local plain=" $time_str"
  local colored="%{%F{cyan}%}$plain%{%f%}"
  __shhac_starship_set_component_output time "$colored" "$plain"
}

# Status: errors, root, background jobs
__shhac_starship_prompt_status() {
  [[ "$SHHAC_THEME_SHOW_STATUS" != "true" ]] && { __shhac_starship_set_component_output status "" ""; return; }
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

  if [[ ${#jobtexts} -gt 0 ]]; then
    symbols+="%{%F{cyan}%}⚙%{%f%}"
    plain_symbols+="⚙"
  fi

  if [[ ${#symbols} -gt 0 ]]; then
    local colored=" ${(j: :)symbols}"
    local plain=" ${(j: :)plain_symbols}"
    __shhac_starship_set_component_output status "$colored" "$plain"
  else
    __shhac_starship_set_component_output status "" ""
  fi
}

# Context: user@hostname (only shown when relevant)
__shhac_starship_prompt_context() {
  [[ "$SHHAC_THEME_SHOW_CONTEXT" != "true" ]] && { __shhac_starship_set_component_output context "" ""; return; }
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    local plain_user="${(%):-%n}"
    local plain_host="${(%):-%m}"
    local plain=" ${plain_user}@${plain_host}"
    local colored=" %{%F{default}%}%(!.%{%F{yellow}%}.)%n@%m%{%f%}"
    __shhac_starship_set_component_output context "$colored" "$plain"
  else
    __shhac_starship_set_component_output context "" ""
  fi
}

# Dir: current working directory
__shhac_starship_prompt_dir() {
  [[ "$SHHAC_THEME_SHOW_PATH" != "true" ]] && { __shhac_starship_set_component_output path "" ""; return; }
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

  local plain=" $result"
  local colored=" %{%F{blue}%}$result%{%f%}"
  __shhac_starship_set_component_output path "$colored" "$plain"
}

# Virtualenv
__shhac_starship_prompt_virtualenv() {
  [[ "$SHHAC_THEME_SHOW_VENV" != "true" ]] && { __shhac_starship_set_component_output venv "" ""; return; }
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    local venv_name="${virtualenv_path:t}"
    local plain=" $venv_name"
    local colored=" %{%F{cyan}%}$__shhac_theme_venv_icon $venv_name%{%f%}"
    __shhac_starship_set_component_output venv "$colored" "$plain"
  else
    __shhac_starship_set_component_output venv "" ""
  fi
}

# Node version
__shhac_starship_prompt_node() {
  [[ "$SHHAC_THEME_SHOW_NODE" != "true" ]] && { __shhac_starship_set_component_output node "" ""; return; }
  if (( __shhac_has_node )); then
    local nv
    nv="$(node --version 2>/dev/null)" || {
      __shhac_starship_set_component_output node "" ""
      return
    }

    # Extract major.minor version using native zsh parameter expansion
    nv="${nv#v}"              # Remove leading 'v'
    local major="${nv%%.*}"   # Get major version
    local rest="${nv#*.}"     # Remove major and first dot
    local minor="${rest%%.*}" # Get minor version
    nv="${major}.${minor}"    # Combine major.minor

    local plain=" $__shhac_theme_node_icon $nv"
    local colored=" %{%F{magenta}%}$__shhac_theme_node_icon $nv%{%f%}"
    __shhac_starship_set_component_output node "$colored" "$plain"
  else
    __shhac_starship_set_component_output node "" ""
  fi
}

# Git - Optimized with single git status call
__shhac_starship_prompt_git() {
  [[ "$SHHAC_THEME_SHOW_GIT" != "true" ]] && { __shhac_starship_set_component_output git "" ""; return; }
  (( __shhac_has_git )) || { __shhac_starship_set_component_output git "" ""; return; }
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    __shhac_starship_set_component_output git "" ""
    return
  fi

  # Set branch character based on font support
  local PL_BRANCH_CHAR
  if (( __shhac_theme_use_powerline )); then
    () {
      local LC_ALL="" LC_CTYPE="en_US.UTF-8"
      PL_BRANCH_CHAR=$'\ue0a0'
    }
  else
    # ASCII fallback for terminals without Powerline fonts
    PL_BRANCH_CHAR='±'
  fi

  # Single git status call with comprehensive output
  local status_output
  status_output=$(git status --porcelain=v2 --branch 2>/dev/null)
  [[ -z $status_output ]] && { __shhac_starship_set_component_output git "" ""; return; }

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

  # Build indicators with new format: change indicator (±) followed by tracking indicators
  local change_indicator=""
  local change_plain=""
  if [[ $has_staged -eq 1 || $has_unstaged -eq 1 ]]; then
    change_indicator="±"
    change_plain="±"
  fi

  local tracking_indicator=""
  local tracking_plain=""
  if [[ $has_upstream -eq 0 && $is_detached -eq 0 ]]; then
    tracking_indicator=" ⚠"
    tracking_plain=" ⚠"
  else
    [[ $ahead -gt 0 ]] && tracking_indicator+=" ↑$ahead" && tracking_plain+=" ↑$ahead"
    [[ $behind -gt 0 ]] && tracking_indicator+=" ↓$behind" && tracking_plain+=" ↓$behind"
  fi

  local indicators="${change_indicator}${tracking_indicator}"
  local plain_indicators="${change_plain}${tracking_plain}"
  [[ -n $indicators ]] && indicators=" $indicators" && plain_indicators=" $plain_indicators"

  # Format branch name
  local branch="${PL_BRANCH_CHAR} ${branch_name}"
  if [[ ${#branch} -gt 30 ]]; then
    branch="${branch:0:29}…"
  fi

  local plain=" $__shhac_theme_git_icon ${branch}${plain_indicators}${mode}"
  local colored=" ${git_color}$__shhac_theme_git_icon ${branch}${indicators}${mode}%{%f%}"
  __shhac_starship_set_component_output git "$colored" "$plain"
}

## Main prompt
build_prompt() {
  local RETVAL=$?

  # Safety check for COLUMNS
  if [[ -z $COLUMNS ]] || [[ $COLUMNS -lt 40 ]]; then
    COLUMNS=${COLUMNS:-80}
  fi

  # Clear component output storage for this render
  __shhac_starship_component_colored=()
  __shhac_starship_component_plain=()

  # Collect all components via loop
  local component
  for component in ${PROMPT_BUBBLE_1[@]} ${PROMPT_BUBBLE_2[@]}; do
    local func=${PROMPT_COMPONENT_FUNCS[$component]}
    if [[ -n $func ]]; then
      $func
    fi
  done

  # Build bubble 1 content
  local bubble1_colored=""
  local bubble1_plain=""
  for component in ${PROMPT_BUBBLE_1[@]}; do
    bubble1_colored+="${__shhac_starship_component_colored[$component]}"
    bubble1_plain+="${__shhac_starship_component_plain[$component]}"
  done

  # Build bubble 2 content
  local bubble2_colored=""
  local bubble2_plain=""
  for component in ${PROMPT_BUBBLE_2[@]}; do
    bubble2_colored+="${__shhac_starship_component_colored[$component]}"
    bubble2_plain+="${__shhac_starship_component_plain[$component]}"
  done

  # Calculate FULL line length including all content (visible characters only)
  # Include: ╭─ (2) + bubble_left (1) + all content + bubble_right (1) = 4 extra chars
  local full_line_plain="╭─${bubble1_plain}${bubble2_plain} "
  local full_line_length=${#full_line_plain}
  local bubble_chars=2  # bubble left + bubble right
  local buffer=12  # increased buffer for safety with unicode/wide chars
  local needed_width=$((full_line_length + bubble_chars + buffer))

  # DEBUG: Uncomment to see calculation
  # echo "DEBUG: full_line_length=$full_line_length, bubble_chars=$bubble_chars, buffer=$buffer, needed=$needed_width, COLUMNS=$COLUMNS" >&2

  # Start prompt
  echo -n "%{%F{242}%}╭─"
  __shhac_theme_bubble_open
  echo -n "${bubble1_colored}"

  # Check if we need line wrap
  if [[ $needed_width -gt $COLUMNS ]]; then
    __shhac_theme_bubble_close
    echo -n "\n%{%F{242}%}├─"
    __shhac_theme_bubble_open
  fi

  # Continue with remaining content
  echo -n "${bubble2_colored}"
  __shhac_theme_bubble_close
}

PROMPT='%{%f%b%k%}$(build_prompt)
%{%F{242}%}╰─%{%F{default}%}❯ '
