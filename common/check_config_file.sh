#!/usr/bin/env bash

BASE_DIR="$(pwd)"
CONSTANTS_PATH="$BASE_DIR/common/constants.sh"

source "$CONSTANTS_PATH"

check_config_file() {
  local mode="$1"  # "exists" or "not_exists"
  
  case "$mode" in
    exists)
      if [ -f "$CONFIG_FILE" ]; then
        echo "❌ Error: Configuration file $CONFIG_FILE already exists. Aborting."
        exit 1
      fi
      ;;
    not_exists)
      if [ ! -f "$CONFIG_FILE" ]; then
        echo "❌ Error: Configuration file not found! Please run 'lzd init' first."
        exit 1
      fi
      ;;
    *)
      echo "❌ Error: Unknown mode '$mode'. Use 'exists' or 'not_exists'."
      exit 1
      ;;
  esac
}

check_config_file "$1"