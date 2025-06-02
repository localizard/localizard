#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status

COMMON_PATH="$(cd -- "$(dirname "$0")/../common" >/dev/null 2>&1 && pwd)"
source "$COMMON_PATH/constants.sh"

bash "$COMMON_PATH/check_config_file.sh" "not_exists"
bash "$COMMON_PATH/check_locale_files.sh"

LOCALES_DIR=$(jq -r '.locales_dir' "$CONFIG_FILE")
LOCALES=$(jq -r '.locales[]' "$CONFIG_FILE")

# Backup directory for rollback
BACKUP_DIR=$(mktemp -d)

# Function to handle rollback on interruption
rollback() {
  echo "⏪ Rolling back changes due to interruption..."
  for locale in $LOCALES; do
    backup_file="$BACKUP_DIR/$locale.json"
    if [ -f "$backup_file" ]; then
      mv "$backup_file" "$LOCALES_DIR/$locale.json"
      echo "✅ Restored: $LOCALES_DIR/$locale.json"
    fi
  done
  echo "🚨 Changes have been rolled back!"
  exit 1
}

# Trap Ctrl+C (SIGINT) and execute rollback function
trap rollback SIGINT

# Create backups of all locale files before modification
for locale in $LOCALES; do
  cp "$LOCALES_DIR/$locale.json" "$BACKUP_DIR/$locale.json"
done

# Function to add localization
add_localization() {
  echo "Enter the JSON key (e.g., sign_in.header.title):"
  read key

  if [ -z "$key" ]; then
    echo "❌ Error: Key cannot be empty. Please enter a valid key."
    exit 1
  fi

  # Validate key: Only letters, numbers, underscore (_) and dot (.)
  if [[ ! "$key" =~ ^[a-zA-Z0-9_\.]+$ ]]; then
    echo "❌ Error: Invalid key format. Only letters (A-Z, a-z), numbers (0-9), underscores (_) and dot (.) are allowed."
    exit 1
  fi

  # Convert key to uppercase
  FORMATTED_KEY=$(echo "$key" | tr '[:lower:]' '[:upper:]')

  # Check if the key already exists in any locale file
  for locale in $LOCALES; do
    locale_file="$LOCALES_DIR/$locale.json"
    
    if bash "$COMMON_PATH/check_key_exists.sh" "$locale_file" "$FORMATTED_KEY"; then
      echo "❌ Error: Key '$FORMATTED_KEY' already exists in $locale_file."
      echo "ℹ️  If you want to edit its value, use the 'lzd edit' command."
      exit 1
    fi
  done

  for locale in $LOCALES; do
    locale_file="$LOCALES_DIR/$locale.json"

    echo "Enter the translation for $locale ($FORMATTED_KEY):"
    read translation

    # Function to update JSON files
    update_json() {
      file="$1"
      key="$2"
      value="$3"

      # Escape double quotes for JSON formatting
      escaped_value=$(echo "$value" | sed 's/"/\\"/g')

      # Convert keys to an array using POSIX-compatible method
      IFS='.' read -r -a keys <<< "$key"
      
      # Generate JQ script
      jq_script="."
      path=""

      for k in "${keys[@]}"; do
        path="$path[\"$k\"]"
        jq_script="$jq_script | .${path} //= {}"
      done

      jq_script="$jq_script | .${path} = \"$escaped_value\""

      # Update the JSON file safely
      jq "$jq_script" "$file" > tmp.json && mv tmp.json "$file"
    }

    update_json "$locale_file" "$FORMATTED_KEY" "$translation"
    echo "✅ Updated: $locale_file"
  done
}

# Loop for multiple entries
while true; do
  add_localization

  echo "Do you want to add another translation? (y/n):"
  read answer

  case "$answer" in
    y|Y) continue ;;
    n|N) break ;;
    *)
      echo "❌ Error: Invalid input, exiting..."
      rollback
    ;;
  esac
done

# Cleanup backup directory after successful completion
rm -rf "$BACKUP_DIR"