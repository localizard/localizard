#!/usr/bin/env bats

BASE_DIR="$(pwd)"
SCRIPT_PATH="$BASE_DIR/scripts"
CONSTANTS_PATH="$BASE_DIR/common/constants.sh"

source "$CONSTANTS_PATH"

setup() {
  mkdir -p tmp
  echo '{"TEST": "test"}' > "tmp/en.json"
  echo '{"TEST": "test"}' > "tmp/hu.json"
  echo '{"locales_dir": "tmp", "locales": ["en", "hu"]}' > "$CONFIG_FILE"
}

teardown() {
  rm -rf tmp
  rm -f "$CONFIG_FILE"
}

@test "add | adds a new key value pair to all locale files and answers 'n' to the continue question and checks the output" {
  run "$SCRIPT_PATH/add.sh" <<EOF
new_key
test
teszt
n
EOF

  [ "$status" -eq 0 ]

  echo "$output" | grep -q "Do you want to add another translation? (y/n):"
  [ "$?" -eq 0 ]

  jq -e '.NEW_KEY == "test"' "tmp/en.json" >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.NEW_KEY == "teszt"' "tmp/hu.json" >/dev/null
  [ "$?" -eq 0 ]
}

@test "add | adds new key values pairs to all locale files and answers 'y' to the continue question" {
  run "$SCRIPT_PATH/add.sh" <<EOF
new_key_1
test_1
teszt_1
y
new_key_2
test_2
teszt_2
n
EOF

  [ "$status" -eq 0 ]

  jq -e '.NEW_KEY_1 == "test_1"' "tmp/en.json" >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.NEW_KEY_1 == "teszt_1"' "tmp/hu.json" >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.NEW_KEY_2 == "test_2"' "tmp/en.json" >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.NEW_KEY_2 == "teszt_2"' "tmp/hu.json" >/dev/null
  [ "$?" -eq 0 ]
}

@test "add | it should work if value contains double quotes" {
  run "$SCRIPT_PATH/add.sh" <<EOF
new_key
"test"
"teszt"
n
EOF

  [ "$status" -eq 0 ]

  jq -e '.NEW_KEY == "\"test\""' "tmp/en.json" >/dev/null
  [ "$?" -eq 0 ]

  jq -e '.NEW_KEY == "\"teszt\""' "tmp/hu.json" >/dev/null
  [ "$?" -eq 0 ]
}

@test  "add | fails when the key already exists in any locale file" {
  run "$SCRIPT_PATH/add.sh" <<EOF
TEST
EOF

  [ "$status" -eq 1 ]

  echo "$output" | grep -q "❌ Error: Key 'TEST' already exists in tmp/en.json."
  [ "$?" -eq 0 ]
    echo "$output" | grep -q "ℹ️  If you want to edit its value, use the 'lzd edit' command."
  [ "$?" -eq 0 ]
}

@test "add | exits when the user provides invalid input to the continue question" {
  run "$SCRIPT_PATH/add.sh" <<EOF
new_key
test
teszt
invalid_input
EOF

  [ "$status" -eq 1 ]

  echo "$output" | grep -q "❌ Error: Invalid input, exiting..."
  [ "$?" -eq 0 ]
}

@test "add | fails when the user provides empty input to the key" {
  run "$SCRIPT_PATH/add.sh" <<EOF

EOF

  [ "$status" -eq 1 ]

  echo "$output" | grep -q "❌ Error: Key cannot be empty. Please enter a valid key."
  [ "$?" -eq 0 ]
}

@test "add | fails when the user provides invalid characters in the key" {
  run "$SCRIPT_PATH/add.sh" <<EOF
="invalid_key"/=
EOF

  [ "$status" -eq 1 ]

  echo "$output" | grep -q "❌ Error: Invalid key format. Only letters (A-Z, a-z), numbers (0-9), and underscores (_) are allowed."
  [ "$?" -eq 0 ]
}
