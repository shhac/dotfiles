# vim:ft=zsh ts=2 sw=2 sts=2
#
# Ataganoster Theme for Oh My Zsh
# ================================
#
# Based on agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH with enhanced git features and performance
#
# Configuration
# -------------
# Add these to your .zshrc BEFORE loading Oh My Zsh to customize the theme:
#
# Component Visibility (hide specific components):
#   export SHHAC_THEME_SHOW_TIME=false       # Hide time in RPROMPT
#   export SHHAC_THEME_SHOW_NODE=false       # Hide Node.js version in RPROMPT
#   export SHHAC_THEME_SHOW_STATUS=false     # Hide error/root/jobs indicators
#   export SHHAC_THEME_SHOW_CONTEXT=false    # Hide user@hostname
#   export SHHAC_THEME_SHOW_PATH=false       # Hide current directory path
#   export SHHAC_THEME_SHOW_VENV=false       # Hide Python virtualenv
#   export SHHAC_THEME_SHOW_GIT=false        # Hide git information
#
# Font Settings:
#   export SHHAC_THEME_USE_POWERLINE=false   # Use ASCII fallback (±, ±, etc.)
#                                            # Default: true (assumes Powerline/Nerd Font available)
#
# Solarized Theme (affects prompt colors):
#   export SOLARIZED_THEME=light             # Use light variant (default: dark)
#
# Requirements
# ------------
# - zsh 5.0+
# - git 2.18+ (recommended for full git features)
# - Powerline-patched font or Nerd Font (recommended, fallback available)
#
# Features
# --------
# - Segmented Powerline-style prompt with directional separators
# - Right-side prompt (RPROMPT) with time and Node.js version
# - Git ahead/behind tracking (↑N ↓N)
# - Git upstream missing indicator (⚠)
# - Signal-decoded error codes (✘→2 for SIGINT)
# - Configurable component visibility
# - ASCII fallback for non-Powerline terminals
# - Performance-optimized git status parsing (single git call)
# - Cached command existence checks
#
# Display Order: status → context → path → virtualenv → git
# RPROMPT: node → time
#

### Initialization and Configuration

# User Configuration: Control component visibility
# Set to false in your .zshrc before theme loads to hide components
: ${SHHAC_THEME_SHOW_TIME:=true}
: ${SHHAC_THEME_SHOW_NODE:=true}
: ${SHHAC_THEME_SHOW_STATUS:=true}
: ${SHHAC_THEME_SHOW_CONTEXT:=true}
: ${SHHAC_THEME_SHOW_PATH:=true}
: ${SHHAC_THEME_SHOW_VENV:=true}
: ${SHHAC_THEME_SHOW_GIT:=true}

# Initialize at theme load
() {
  # Initialize git/vcs_info settings once
  setopt promptsubst
  autoload -Uz vcs_info

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' get-revision true
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' stagedstr '✚'
  zstyle ':vcs_info:*' unstagedstr '●'
  zstyle ':vcs_info:*' formats ' %u%c'
  zstyle ':vcs_info:*' actionformats ' %u%c'

  # Cache command existence for performance
  typeset -g __shhac_has_git __shhac_has_node
  (( $+commands[git] )) && __shhac_has_git=1 || __shhac_has_git=0
  (( $+commands[node] )) && __shhac_has_node=1 || __shhac_has_node=0
}

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='black';;
esac

# User-configurable Powerline/Nerd Font support
# Set SHHAC_THEME_USE_POWERLINE=false in your .zshrc to disable
() {
  if [[ "${SHHAC_THEME_USE_POWERLINE:-true}" == "false" ]]; then
    typeset -g __shhac_theme_use_powerline=0
    # ASCII fallback characters
    SEGMENT_SEPARATOR='>'
    SEGMENT_SEPARATOR_R='<'
    typeset -g __shhac_theme_branch_char='±'
    typeset -g __shhac_theme_node_icon='n:'
  else
    typeset -g __shhac_theme_use_powerline=1
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    # NOTE: This segment separator character is correct.  In 2012, Powerline changed
    # the code points they use for their special characters. This is the new code point.
    # If this is not working for you, you probably have an old version of the
    # Powerline-patched fonts installed. Download and install the new version.
    # Do not submit PRs to change this unless you have reviewed the Powerline code point
    # history and have new information.
    # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
    # what font the user is viewing this source code in. Do not replace the
    # escape sequence with a single literal character.
    # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
    SEGMENT_SEPARATOR=$'\ue0b0'
    SEGMENT_SEPARATOR_R=$'\ue0b2'
    typeset -g __shhac_theme_branch_char=$'\ue0a0'  #
    typeset -g __shhac_theme_node_icon='⬢'
  fi
}

# RHS version of segments
rprompt_segment() {
  local bg fg se
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  [[ -n $1 ]] && se="%F{$1}" || se="%F{black}"
  if [[ $1 != $CURRENT_BG ]]; then
    echo -n " %{$se%}$SEGMENT_SEPARATOR_R"
  fi
  echo -n "%{$bg%}%{$fg%} "
  CURRENT_BG=$1 
  [[ -n $3 ]] && echo -n $3
}

rprompt_end() {
  echo -n "%{%k%}"
  echo -n "%{%f%}"
  CURRENT_BG=''
}

rprompt_time() {
  [[ "$SHHAC_THEME_SHOW_TIME" != "true" ]] && return
  local time_fmt="%D{%H:%M:%S}"
  local time_str="${(%)time_fmt}"
  rprompt_segment 008 250 "$time_str "
}

rprompt_rig() {
  local nom
  nom="$(rig -c 1 | head -1)"
  rprompt_segment 237 200 "$nom"
}

rprompt_node() {
  [[ "$SHHAC_THEME_SHOW_NODE" != "true" ]] && return
  if (( __shhac_has_node )); then
    local nv
    nv="$(node --version 2>/dev/null)" || return

    # Extract major.minor version using native zsh parameter expansion
    nv="${nv#v}"              # Remove leading 'v'
    local major="${nv%%.*}"   # Get major version
    local rest="${nv#*.}"     # Remove major and first dot
    local minor="${rest%%.*}" # Get minor version
    nv="${major}.${minor}"    # Combine major.minor

    rprompt_segment 170 237 "$nv $__shhac_theme_node_icon"
  fi
}

build_rprompt() {
  # rprompt_rig
  rprompt_node
  rprompt_time
  rprompt_end
}

#RPROMPT='%{%F{008}%}$SEGMENT_SEPARATOR_R%{%K{008}%}%{%F{250}%} %* %{%k%}%{%f%}'
RPROMPT='$(build_rprompt)'

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
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
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  [[ "$SHHAC_THEME_SHOW_CONTEXT" != "true" ]] && return
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)%n@%m"
  fi
}

# Git: branch/detached head, dirty status - Optimized with single git status call
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
  if [[ $has_staged -eq 1 || $has_unstaged -eq 1 ]]; then
    prompt_segment yellow black
  else
    prompt_segment green $CURRENT_FG
  fi

  # Build indicators: change indicator (±) followed by tracking indicators
  local indicators=""
  if [[ $has_staged -eq 1 || $has_unstaged -eq 1 ]]; then
    indicators="±"
  fi

  if [[ $has_upstream -eq 0 && $is_detached -eq 0 ]]; then
    indicators+=" ⚠"
  else
    [[ $ahead -gt 0 ]] && indicators+=" ↑$ahead"
    [[ $behind -gt 0 ]] && indicators+=" ↓$behind"
  fi

  [[ -n $indicators ]] && indicators=" $indicators"

  # Format branch name with appropriate character based on font support
  local branch="$__shhac_theme_branch_char ${branch_name}"
  if [[ ${#branch} -gt 30 ]]; then
    branch="${branch:0:29}…"
  fi

  echo -n "${branch}${indicators}${mode}"
}

prompt_bzr() {
    (( $+commands[bzr] )) || return
    if (bzr status >/dev/null 2>&1); then
        status_mod=`bzr status | head -n1 | grep "modified" | wc -m`
        status_all=`bzr status | head -n1 | wc -m`
        revision=`bzr log | head -n2 | tail -n1 | sed 's/^revno: //'`
        if [[ $status_mod -gt 0 ]] ; then
            prompt_segment yellow black
            echo -n "bzr@"$revision "✚ "
        else
            if [[ $status_all -gt 0 ]] ; then
                prompt_segment yellow black
                echo -n "bzr@"$revision

            else
                prompt_segment green black
                echo -n "bzr@"$revision
            fi
        fi
    fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev st branch
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment red white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black
        st='±'
      else
        # if working copy is clean
        prompt_segment green $CURRENT_FG
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -q "^\?"`; then
        prompt_segment red black
        st='±'
      elif `hg st | grep -q "^[MA]"`; then
        prompt_segment yellow black
        st='±'
      else
        prompt_segment green $CURRENT_FG
      fi
      echo -n "☿ $rev@$branch" $st
    fi
  fi
}

# Dir: current working directory
prompt_dir () {
  [[ "$SHHAC_THEME_SHOW_PATH" != "true" ]] && return
  local path='%(4~|%-1~/…/%2~|%~)'
  # Expand the path first
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

  prompt_segment blue $CURRENT_FG "$result"
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  [[ "$SHHAC_THEME_SHOW_VENV" != "true" ]] && return
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment blue black "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  [[ "$SHHAC_THEME_SHOW_STATUS" != "true" ]] && return
  local -a symbols

  if [[ $RETVAL -ne 0 ]]; then
    symbols+="%{%F{red}%}✘"
    if [[ $RETVAL -gt 128 ]]; then
      local realret="$(($RETVAL-128))"
      symbols+="→$realret"
    else
      symbols+=" $RETVAL"
    fi
  fi
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  prompt_bzr
  prompt_hg
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
