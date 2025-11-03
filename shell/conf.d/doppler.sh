if ! [ -z "$(command -v doppler)" ]; then

  dope() {
    if [ -f ".nvmrc" ] && ! [ -z "$(command -v nvm)" ]; then
      nvm use
    fi
    local flags=()
    flags+=("--preserve-env")
    flags+=("--config" ${1})

    local command=()
    command+=(${@:2})

    doppler run ${flags} -- ${command}
  }

fi
