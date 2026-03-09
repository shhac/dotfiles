[[ "$(uname)" == "Darwin" ]] || return 0

if [ -d "/Applications/Sublime Text.app/Contents/SharedSupport/bin" ]; then
  export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
fi

