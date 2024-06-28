eval $(thefuck --alias eep)

alias esfix="eslint --fix --"
alias vlog="less +JFR"
alias did="vim +'normal Go' +'r!date' ~/did.txt"

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

