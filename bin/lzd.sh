#!/usr/bin/env bash

# Get the directory of the script
BASE_DIR="${BASE_DIR:-$(cd -- "$(dirname "$(realpath "$0")")" >/dev/null 2>&1 || exit; pwd -P)}"

# Check if running from global install
if [ ! -d "$BASE_DIR/scripts" ]; then 
# If running from npm global install, go one level up
  BASE_DIR="$(cd "$BASE_DIR/.." >/dev/null 2>&1 || exit; pwd -P)"
fi

# Define the scripts directory
SCRIPTS_DIR="$BASE_DIR/scripts"

# Ensure scripts directory exists
if [ ! -d "$SCRIPTS_DIR" ]; then
  echo "❌ Error: Scripts directory not found at $SCRIPTS_DIR"
  exit 1
fi

show_help() {
  echo "===================================="
  echo "           🦎 LOCALIZARD            "
  echo "===================================="
  echo ""
  echo "Usage:"
  echo "  lzd [command] [options]"
  echo ""
  echo "Available commands:"
  echo "  init          - Initialize locales JSON files"
  echo "      Options:"
  echo "        --new, -n   Create new locale files"
  echo "        --link, -l  Use existing locale files"
  echo ""
  echo "  add           - Add a new translation key to locales JSON"
  echo "  edit          - Modify a translation value in locales JSON"
  echo "      Options:"
  echo "        --files, -f <locales>   Specify which locales to modify (comma-separated, e.g., hu,en,de)"
  echo ""
  echo "  delete        - Delete a translation key from locales JSON"
  echo ""
  echo "Use 'lzd --help' to show this help message."
  echo ""
  echo "Note: Running 'lzd' without arguments will start the interactive CLI."
  exit 0
}

execute_command() {
  case "$1" in
    init) sh "$SCRIPTS_DIR/init.sh" "$2" ;;
    add) sh "$SCRIPTS_DIR/add.sh" ;;
    edit)
      shift
      sh "$SCRIPTS_DIR/edit.sh" "$@"
      ;;
    delete) sh "$SCRIPTS_DIR/delete.sh" ;;
    clear) sh "$SCRIPTS_DIR/clear.sh" ;;
    --help|-h) show_help ;;
    *)
      echo "❌ Unknown command: $1"
      show_help
      ;;
  esac
}

# If an argument is provided, execute the corresponding script
if [ "$#" -gt 0 ]; then
  execute_command "$@"
  exit 0
fi

show_menu() {
  clear
  echo "===================================="
  echo "           🦎 LOCALIZARD            "
  echo "===================================="
  echo ""
  echo "Available commands:"
  echo "  1) Init           - Initialize locales JSON files"
  echo "  2) Add            - Add a new translation key to locales JSON"
  echo "  3) Edit           - Modify a translation value in locales JSON"
  echo "  4) Delete         - Delete a translation key from locales JSON"
  echo "  5) Exit"
  echo ""
}

# Menu loop
while true; do
  show_menu
  printf "Enter a number and press ENTER: "
  read user_input

  case "$user_input" in
    1) execute_command "init" ;;
    2) execute_command "add" ;;
    3) execute_command "edit" ;;
    4) execute_command "delete" ;;
    5) echo "👋 Exiting..."; exit 0 ;;
    *) echo "❌ Invalid option. Please try again." ;;
  esac

  printf "\nPress ENTER to continue..."
  read _
done