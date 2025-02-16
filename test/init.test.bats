#!/usr/bin/env bats

BASE_DIR="$(pwd)"
SCRIPT_PATH="$BASE_DIR/scripts"
CONSTANTS_PATH="$BASE_DIR/common/constants.sh"

source "$CONSTANTS_PATH"

cleanup_files() {
  rm -f $CONFIG_FILE
  rm -rf src
  rm -f en.json hu.json
}

@test "init | fails with error on invalid input for y/n question" {
  run "$SCRIPT_PATH/init.sh" <<EOF
invalid_input
EOF

  # Check that the command failed
  [ "$status" -eq 1 ]

  # Verify the error message
  echo "$output" | grep -q "❌ Invalid input. Please enter 'y' or 'n'."
  [ "$?" -eq 0 ]
}

@test "init | fails with error on invalid option" {
  run "$SCRIPT_PATH/init.sh" --invalid-option

  # Check that the command failed
  [ "$status" -eq 1 ]

  # Verify the error message
  echo "$output" | grep -q "❌ Error: Invalid option '--invalid-option'. Please use 'lzd --help' to see the list of available options."
  [ "$?" -eq 0 ]
}

@test "init --new | creates a new config file with correct content and prompts" {
  run "$SCRIPT_PATH/init.sh" --new <<EOF
hu,en
src/locales
EOF

  # Check that the command ran successfully
  [ "$status" -eq 0 ]
  # Verify that the config file was created
  [ -f "$CONFIG_FILE" ]

  # Check that the interactive prompts appeared correctly
  echo "$output" | grep -q "Enter the JSON file names for locales (comma-separated, e.g., en,hu,fr):"
  [ "$?" -eq 0 ] # Verify that the first prompt appeared correctly
  echo "$output" | grep -q "Enter the path where the locale files should be stored (e.g., src/localization/locales):"
  [ "$?" -eq 0 ] # Verify that the second prompt appeared correctly

  # Check the content of the config file
  jq -e '.locales_dir == "src/locales"' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.locales | index("hu") and index("en")' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  cleanup_files
}

@test "init -n | it should work as an alias for --new" {
  run "$SCRIPT_PATH/init.sh" --new <<EOF
hu,en
src/locales
EOF

  # Check that the command ran successfully
  [ "$status" -eq 0 ]
  # Verify that the config file was created
  [ -f "$CONFIG_FILE" ]

  # Check that the interactive prompts appeared correctly
  echo "$output" | grep -q "Enter the JSON file names for locales (comma-separated, e.g., en,hu,fr):"
  [ "$?" -eq 0 ] # Verify that the first prompt appeared correctly
  echo "$output" | grep -q "Enter the path where the locale files should be stored (e.g., src/localization/locales):"
  [ "$?" -eq 0 ] # Verify that the second prompt appeared correctly

  # Check the content of the config file
  jq -e '.locales_dir == "src/locales"' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.locales | index("hu") and index("en")' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  cleanup_files
}

@test "init | behaves like --new when answering 'y' to create new files" {
  run "$SCRIPT_PATH/init.sh" <<EOF
y
hu,en
src/locales
EOF

  # Check that the command ran successfully
  [ "$status" -eq 0 ]

  # Verify that the config file was created
  [ -f "$CONFIG_FILE" ]

  # Check that the interactive prompts appeared correctly
  echo "$output" | grep -q "Would you like to initialize new locale files? (y/n)"
  [ "$?" -eq 0 ] # Verify that the initial question appeared
  echo "$output" | grep -q "Enter the JSON file names for locales (comma-separated, e.g., en,hu,fr):"
  [ "$?" -eq 0 ] # Verify that the first input prompt appeared
  echo "$output" | grep -q "Enter the path where the locale files should be stored (e.g., src/localization/locales):"
  [ "$?" -eq 0 ] # Verify that the second input prompt appeared

  # Check the content of the config file
  jq -e '.locales_dir == "src/locales"' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.locales | index("hu") and index("en")' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  cleanup_files
}

@test "init --new | uses project root as default locales_dir if no path is provided" {
  run "$SCRIPT_PATH/init.sh" --new <<EOF
hu,en

EOF

  # Check that the command ran successfully
  [ "$status" -eq 0 ]

  # Verify that the config file was created
  [ -f "$CONFIG_FILE" ]

  # Check that the interactive prompts appeared correctly
  echo "$output" | grep -q "Enter the JSON file names for locales (comma-separated, e.g., en,hu,fr):"
  [ "$?" -eq 0 ] # Verify that the first prompt appeared correctly
  echo "$output" | grep -q "Enter the path where the locale files should be stored (e.g., src/localization/locales):"
  [ "$?" -eq 0 ] # Verify that the second prompt appeared correctly

  # Check for the info message about using the project root
  echo "$output" | grep -q "ℹ️ Using project root as the locales directory."
  [ "$?" -eq 0 ] # Verify that the info message appeared

  # Check the content of the config file
  jq -e '.locales_dir == "."' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.locales | index("hu") and index("en")' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  cleanup_files
}

@test "init --new | it should fail if the config file already exists" {
  touch "$CONFIG_FILE"
  run "$SCRIPT_PATH/init.sh" --new

  # Check that the command failed
  [ "$status" -eq 1 ]

  # Check that the error message appeared correctly
  echo "$output" | grep -q "❌ Error: Configuration file $CONFIG_FILE already exists. Aborting"
  [ "$?" -eq 0 ]

  cleanup_files
}

@test "init --new | it should fail if no valid locales provided" {
  run "$SCRIPT_PATH/init.sh" --new <<EOF
,
EOF

  # Check that the command failed
  [ "$status" -eq 1 ]

  # Check that the error message appeared correctly
  echo "$output" | grep -q "❌ Error: No valid locales provided. Please specify at least one locale name."
  [ "$?" -eq 0 ]
}


@test "init --link | creates a new config file with correct content when valid locales exist" {
  mkdir -p src/locales
  echo '{}' > src/locales/en.json
  echo '{}' > src/locales/hu.json

  run "$SCRIPT_PATH/init.sh" --link <<EOF
src/locales
EOF

  # Check that the command ran successfully
  [ "$status" -eq 0 ]

  # Verify that the config file was created
  [ -f "$CONFIG_FILE" ]

  # Check that the interactive prompts appeared correctly
  echo "$output" | grep -q "Enter the path to the existing locale files (e.g., src/localization/locales):"
  [ "$?" -eq 0 ] # Verify that the prompt appeared correctly

  # Check the content of the config file
  jq -e '.locales_dir == "src/locales"' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.locales | index("en") and index("hu")' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  cleanup_files
}

@test "init -l | it should work as an alias for --link" {
  mkdir -p src/locales
  echo '{}' > src/locales/en.json
  echo '{}' > src/locales/hu.json

  run "$SCRIPT_PATH/init.sh" --link <<EOF
src/locales
EOF

  # Check that the command ran successfully
  [ "$status" -eq 0 ]

  # Verify that the config file was created
  [ -f "$CONFIG_FILE" ]

  # Check that the interactive prompts appeared correctly
  echo "$output" | grep -q "Enter the path to the existing locale files (e.g., src/localization/locales):"
  [ "$?" -eq 0 ] # Verify that the prompt appeared correctly

  # Check the content of the config file
  jq -e '.locales_dir == "src/locales"' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.locales | index("en") and index("hu")' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  cleanup_files
}

@test "init | behaves like --link when answering 'n' to create new files" {
  mkdir -p src/locales
  echo '{}' > src/locales/en.json
  echo '{}' > src/locales/hu.json

  run "$SCRIPT_PATH/init.sh" <<EOF
n
src/locales
EOF

  # Check that the command ran successfully
  [ "$status" -eq 0 ]

  # Verify that the config file was created
  [ -f "$CONFIG_FILE" ]

  # Check that the interactive prompts appeared correctly
  echo "$output" | grep -q "Would you like to initialize new locale files? (y/n)"
  [ "$?" -eq 0 ] # Verify that the initial question appeared
  echo "$output" | grep -q "Enter the path to the existing locale files (e.g., src/localization/locales):"
  [ "$?" -eq 0 ] # Verify that the prompt appeared correctly

  # Check the content of the config file
  jq -e '.locales_dir == "src/locales"' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.locales | index("en") and index("hu")' $CONFIG_FILE >/dev/null
  [ "$?" -eq 0 ]

  cleanup_files
}

@test "init --link | fails when the specified directory does not exist" {
  run "$SCRIPT_PATH/init.sh" --link <<EOF
nonexistent/locales
EOF

  # Check that the command failed
  [ "$status" -eq 1 ]

  # Verify the error message
  echo "$output" | grep -q "❌ Error: Directory not found at nonexistent/locales"
  [ "$?" -eq 0 ]
}

@test "init --link | fails when no .json files are found in the directory" {
  mkdir -p src/locales_empty

  run "$SCRIPT_PATH/init.sh" --link <<EOF
src/locales_empty
EOF

  # Check that the command failed
  [ "$status" -eq 1 ]

  # Verify the error message
  echo "$output" | grep -q "❌ Error: No .json files found in src/locales_empty"
  [ "$?" -eq 0 ]

  cleanup_files
}

@test "init --link | it should fail if the config file already exists" {
  touch "$CONFIG_FILE"
  run "$SCRIPT_PATH/init.sh" --link

  # Check that the command failed
  [ "$status" -eq 1 ]

  # Check that the error message appeared correctly
  echo "$output" | grep -q "❌ Error: Configuration file $CONFIG_FILE already exists. Aborting"
  [ "$?" -eq 0 ]

  cleanup_files
}