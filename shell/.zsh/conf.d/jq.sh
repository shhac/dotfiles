jq-modify() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <json-file> <jq-query>"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    return 1
  fi
  mv "$1" "$1.bak"
  jq "$2" "$1.bak" > "$1"
  rm "$1.bak"
}
package-version() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <version>"
  else
    jq-modify './package.json' '.version = "'"$1"'"'
    jq-modify './package-lock.json' '.version = "'"$1"'"'
    jq-modify './package-lock.json' '.packages[""].version = "'"$1"'"'
  fi
}
