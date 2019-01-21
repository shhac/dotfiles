nr() {
  if [ -f ".nvmrc" ] && ! [ -z "$(command -v nvm)" ]; then
    nvm use
  fi
  npm run "${@}"
}
