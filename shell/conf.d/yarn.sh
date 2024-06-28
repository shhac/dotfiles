if ! [ -z "$(command -v yarn)" ]; then
  y() {
    if [ -f ".nvmrc" ] && ! [ -z "$(command -v nvm)" ]; then
      nvm use
    fi
    yarn "${@}"
  }

  dy() {
    if [ -f ".nvmrc" ] && ! [ -z "$(command -v nvm)" ]; then
      nvm use
    fi
    local flags=()
    flags+=("--preserve-env")
    flags+=("--config" ${1})

    local command=()
    command+=("yarn" ${@:2})

    doppler run ${flags} -- ${command}
  }
fi
