#!/usr/bin/env bash
set -euo pipefail

LOCK_FILE="${1:-$HOME/.agents/.skill-lock.json}"

if [ ! -f "$LOCK_FILE" ]; then
  echo "No skills lock found at $LOCK_FILE"
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to install skills from $LOCK_FILE" >&2
  exit 1
fi

if command -v npx >/dev/null 2>&1; then
  skills_cmd=(npx -y skills)
elif command -v bunx >/dev/null 2>&1; then
  skills_cmd=(bunx skills)
else
  echo "npx or bunx is required to install skills" >&2
  exit 1
fi

agent_args=()
agent_arg_count=0
if [ -n "${DOTFILES_SKILLS_AGENTS:-}" ]; then
  IFS=',' read -r -a agents <<< "$DOTFILES_SKILLS_AGENTS"
  for agent in "${agents[@]}"; do
    if [ -n "$agent" ]; then
      agent_args+=("-a" "$agent")
      agent_arg_count=$((agent_arg_count + 2))
    fi
  done
fi

jq -r '.skills | to_entries | group_by(.value.source)[] | [.[0].value.source, (map(.key) | join(","))] | @tsv' "$LOCK_FILE" |
while IFS=$'\t' read -r source skills_csv; do
  [ -n "$source" ] || continue
  IFS=',' read -r -a skill_names <<< "$skills_csv"

  cmd=("${skills_cmd[@]}" add "$source" -g -y)
  for skill_name in "${skill_names[@]}"; do
    [ -n "$skill_name" ] && cmd+=("--skill" "$skill_name")
  done
  if [ "$agent_arg_count" -gt 0 ]; then
    cmd+=("${agent_args[@]}")
  fi

  echo "Installing skills from $source"
  "${cmd[@]}"
done
