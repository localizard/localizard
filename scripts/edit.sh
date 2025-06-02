#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status

COMMON_PATH="$(cd -- "$(dirname "$0")/../common" >/dev/null 2>&1 && pwd)"
source "$COMMON_PATH/constants.sh"

sh "$COMMON_PATH/check_config_file.sh" "not_exists"

# Read values from the JSON config using `jq`
LOCALES_DIR=$(jq -r '.locales_dir' "$CONFIG_FILE")
ALL_LOCALES=$(jq -r '.locales[]' "$CONFIG_FILE")

# Function to parse command-line arguments
parse_arguments() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --files|-f)
        if [ -n "$2" ]; then
          LOCALES=$(echo "$2" | tr ',' ' ')
          shift 2
        else
          echo "❌ Error: --files option requires an argument."
          exit 1
        fi
        ;;
      *)
        shift
        ;;
    esac
  done
}

# Parse command-line arguments
parse_arguments "$@"

# If no --files option was provided, ask interactively
if [ -z "$LOCALES" ]; then
  echo "Enter the locales you want to modify (comma-separated, e.g., hu,en,de). Leave empty to modify all:"
  read locales_input
  if [ -z "$locales_input" ]; then
    LOCALES=$ALL_LOCALES
  else
    LOCALES=$(echo "$locales_input" | tr ',' ' ')
  fi
fi

# Check if the locale files exist
LOCALES=$(echo "$LOCALES" | tr ' ' '\n' | grep -v '^$' | tr '\n' ' ')
if [ "$(echo "$LOCALES" | wc -w)" -eq 1 ]; then
  bash "$COMMON_PATH/check_locale_files.sh" "$LOCALES"
else
  bash "$COMMON_PATH/check_locale_files.sh"
fi

# Prompt for the key to modify
echo "Enter the JSON key to modify (e.g., sign_in.header.title):"
read key

# Convert the key to uppercase
FORMATTED_KEY=$(echo "$key" | tr '[:lower:]' '[:upper:]')

# Verify if the key exists in all selected locale files
for locale in $LOCALES; do
  locale_file="$LOCALES_DIR/$locale.json"
  if ! bash "$COMMON_PATH/check_key_exists.sh" "$locale_file" "$FORMATTED_KEY"; then
    echo "❌ Error: Key '$FORMATTED_KEY' not found in $locale_file"
    exit 1
  fi
done

# Prompt for new translations for each selected locale
translations=""
for locale in $LOCALES; do
  echo "Enter the new translation for $locale ($FORMATTED_KEY):"
  read value
  translations="$translations$locale:$value\n"
done

# Function to modify a key in the JSON file
modify_json() {
  file="$1"
  key="$2"
  value="$3"
  tmp_file="${file}.tmp"

  jq ".${key} = \"$value\"" "$file" > "$tmp_file" && mv "$tmp_file" "$file"
}

# Update each selected locale JSON file
echo "$translations" | grep -v '^:$' | while IFS=: read -r locale value; do
  if [ -z "$locale" ] || [ -z "$value" ]; then
    continue  # Skip empty entries
  fi

  locale_file="$LOCALES_DIR/$locale.json"
  modify_json "$locale_file" "$FORMATTED_KEY" "$value"
  echo "✅ Updated: $locale_file"
done

echo "✅ Localization modified successfully!"