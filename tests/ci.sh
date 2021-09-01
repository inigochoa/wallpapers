#!/bin/bash

set -e

MINHEIGHT=1080
MINWIDTH=1920

print_error() {
  echo "Failure! $1 See README.md."

  exit 1
}

test_artist() {
  local ERROR="$1 missing Artist metadata!"
  local ARTIST="$(exif --tag=Artist --no-fixup -m "$1")" || print_error "$ERROR"

  if [ "$(echo "$ARTIST" | wc -m)" -lt 3 ]; then
    print_error "$ERROR"
  fi
}

test_dimensions() {
  local ERROR="$1 has invalid dimensions!"
  local HEIGHT="$(identify -format '%h' "$1")" || print_error "$ERROR"
  local WIDTH="$(identify -format '%w' "$1")" || print_error "$ERROR"

  if [ $HEIGHT -lt $MINHEIGHT ] || [ $WIDTH -lt $MINWIDTH ]; then
    print_error "$ERROR"
  fi
}

test_license() {
  local ERROR="$1 has no license!"
  local FILENAME="$(basename $1 | cut -d. -f1)"

  grep -qE " $FILENAME " ./LICENSE.md || print_error "$ERROR"
}

test_name() {
  local ERROR="$1 has invalid name!"

  if [[ "$1" = *" "* ]] || [[ "$1" = *"_"* ]]; then
    print_error "$ERROR"
  fi
}

for IMAGE in ./images/*.jpg; do
  test_artist "$IMAGE"
  test_dimensions "$IMAGE"
  test_license "$IMAGE"
  test_name "$IMAGE"
done

echo "Success! Wallpapers validated."
