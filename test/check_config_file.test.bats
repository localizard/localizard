#!/usr/bin/env bats

COMMON_PATH="$(cd -- "$(dirname "${BATS_TEST_FILENAME}")/../common" >/dev/null 2>&1 && pwd)"
source "$COMMON_PATH/constants.sh"

setup() {
  rm -f "$CONFIG_FILE"  
}

teardown() {
  rm -f "$CONFIG_FILE"  
}

@test "mode = exists | no config file, runs without error" {
  run "$COMMON_PATH/check_config_file.sh" "exists"
  [ "$status" -eq 0 ]
}

@test "mode = exists | config file exists, throws error" {
  touch "$CONFIG_FILE"  
  run "$COMMON_PATH/check_config_file.sh" "exists"
  [ "$status" -eq 1 ]
  echo "$output" | grep -q "❌ Error: Configuration file $CONFIG_FILE already exists. Aborting."
}

@test "mode = not_exists | config file exists, runs without error" {
  touch "$CONFIG_FILE" 
  run "$COMMON_PATH/check_config_file.sh" "not_exists"
  [ "$status" -eq 0 ]
}

@test "mode = not_exists | no config file, throws error" {
  run "$COMMON_PATH/check_config_file.sh" "not_exists"
  [ "$status" -eq 1 ]
  echo "$output" | grep -q "❌ Error: Configuration file not found! Please run 'lzd init' first."
}

@test "mode = invalid_mode | throws error with unknown mode" {
  run "$COMMON_PATH/check_config_file.sh" "invalid_mode"
  [ "$status" -eq 1 ]
  echo "$output" | grep -q "❌ Error: Unknown mode 'invalid_mode'. Use 'exists' or 'not_exists'."
}