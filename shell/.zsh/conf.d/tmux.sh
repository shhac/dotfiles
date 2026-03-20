# Directory-based tmux sessions
tmux() {
  if [[ $# -eq 0 ]]; then
    # No arguments: smart session management

    if ! command tmux info &>/dev/null; then
      command tmux start-server
      # Wait for resurrect plugin to restore sessions if saved state exists
      if [[ -f ~/.tmux/resurrect/last ]]; then
        for i in {1..10}; do
          command tmux has-session 2>/dev/null && break
          sleep 0.5
        done
      fi
    fi

    local session_name=$(basename "$PWD" | tr '~' 'HOME' | tr '/' 'ROOT' | tr '.' '_')
    session_name="${session_name:-HOME}"

    if command tmux has-session -t "$session_name" 2>/dev/null; then
      command tmux attach-session -t "$session_name"
    else
      command tmux new-session -s "$session_name"
    fi
  else
    # Has arguments: pass through to real tmux
    command tmux "$@"
  fi
}

