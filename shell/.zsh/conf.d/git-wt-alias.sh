#!/usr/bin/env zsh

# Only unalias if gwt alias exists
alias gwt &>/dev/null && unalias gwt

if command -v git-wt &>/dev/null; then
  eval "$(git-wt alias gwt)"
fi
