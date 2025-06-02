#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status

COMMON_PATH="$(cd -- "$(dirname "$0")/../common" >/dev/null 2>&1 && pwd)"
source "$COMMON_PATH/constants.sh"

bash "$COMMON_PATH/check_config_file.sh" "not_exists"
bash "$COMMON_PATH/check_locale_files.sh"

# Read values from the JSON config using `jq`
LOCALES_DIR=$(jq -r '.locales_dir' "$CONFIG_FILE")
LOCALES=$(jq -r '.locales[]' "$CONFIG_FILE")

# Prompt for the key to delete
echo "Enter the JSON key to delete (e.g., sign_in.header.title):"
read key

# Convert the key to uppercase
FORMATTED_KEY=$(echo "$key" | tr '[:lower:]' '[:upper:]')

# Function to check if a key exists in a JSON file
key_exists() {
  file="$1"
  key="$2"

  # Convert key into an array
  IFS='.' read -r -a keys <<< "$key"

  # Construct JQ path
  path=""
  for k in "${keys[@]}"; do
    path="$path[\"$k\"]"
  done

  # Check if the key exists
  if jq -e ".${path} // empty" "$file" >/dev/null 2>&1; then
    return 0  # Exists
  else
    return 1  # Does not exist
  fi
}

# Verify if the key exists in all locale files
for locale in $LOCALES; do
  locale_file="$LOCALES_DIR/$locale.json"
  if ! key_exists "$locale_file" "$FORMATTED_KEY"; then
    echo "❌ Error: Key '$FORMATTED_KEY' not found in $locale_file"
    exit 1
  fi
done

# Function to delete a key from the JSON file
delete_json() {
  file="$1"
  key="$2"

  # Convert key into an array
  IFS='.' read -r -a keys <<< "$key"

  # Construct the JQ delete command
  jq_script="del(.${keys[0]}"
  for ((i=1; i<${#keys[@]}; i++)); do
    jq_script="$jq_script[\"${keys[i]}\"]"
  done
  jq_script="$jq_script)"

  # Update the JSON file
  jq "$jq_script" "$file" > tmp.json && mv tmp.json "$file"

  echo "✅ Deleted key: $key from $file"

  # Remove empty objects **without setting null values**
  clean_json "$file"
}

# Function to remove empty objects **without affecting non-empty objects**
clean_json() {
  file="$1"

  # JQ script to recursively remove empty objects while keeping non-empty ones
  clean_script='walk(if type == "object" then with_entries(select(.value != {})) else . end)'

  jq "$clean_script" "$file" > tmp.json && mv tmp.json "$file"

  echo "🧹 Cleaned empty objects in: $file"
}

# Delete the key from all locale files
for locale in $LOCALES; do
  locale_file="$LOCALES_DIR/$locale.json"
  delete_json "$locale_file" "$FORMATTED_KEY"
done

echo "✅ Localization key deleted and cleaned successfully!"