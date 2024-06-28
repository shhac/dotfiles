convert-screen-recording() {
  echo "About to convert\n    $1\n  to\n   ${1%.mov}.mp4"
  ffmpeg -i $1 -codec:a aac -codec:v h264 "${1%.mov}.mp4" \
    && [ -f "${1%.mov}.mp4" ] \
    && rm $1 \
    && echo "Converted to ${1%.mov}.mp4" \
    || echo "Something went wrong converting $1"
}
