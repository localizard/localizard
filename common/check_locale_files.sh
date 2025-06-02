#!/usr/bin/env bash

BASE_DIR="${BASE_DIR:-$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)}"
CONSTANTS_PATH="$BASE_DIR/common/constants.sh"

source "$CONSTANTS_PATH"

check_locale_files() {
  local locales_dir=$(jq -r '.locales_dir' "$CONFIG_FILE")

  if [ -n "$1" ]; then
    local locale="$1"
    local locale_file="$locales_dir/$locale.json"
    if [ ! -f "$locale_file" ]; then
      echo "❌ Error: Missing locale file: $locale_file"
      exit 1
    fi
    return
  fi

  local locales=$(jq -r '.locales[]' "$CONFIG_FILE")
  for locale in $locales; do
    local locale_file="$locales_dir/$locale.json"
    if [ ! -f "$locale_file" ]; then
      echo "❌ Error: Missing locale file: $locale_file"
      exit 1
    fi
  done
}

check_locale_files "$1"