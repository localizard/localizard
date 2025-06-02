check_key_exists() {
  local file="$1"
  local key="$2"

  # Convert key to dot notation path
  IFS='.' read -r -a keys <<< "$key"
  jq_query="."

  for k in "${keys[@]}"; do
    jq_query="$jq_query[\"$k\"]"
  done

  # Check if the key exists and is not null
  if jq -e "$jq_query != null" "$file" >/dev/null 2>&1; then
    return 0 # Key exists
  else
    return 1 # Key does not exist
  fi
}

check_key_exists "$1" "$2"