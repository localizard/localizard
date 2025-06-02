#!/usr/bin/env bats

COMMON_PATH="$(cd -- "$(dirname "${BATS_TEST_FILENAME}")/../common" >/dev/null 2>&1 && pwd)"
source "$COMMON_PATH/constants.sh"

setup() {
    mkdir -p tmp/locales
    echo '{"locales_dir": "tmp/locales", "locales": ["en", "hu"]}' > "$CONFIG_FILE"
    echo '{}' > "tmp/locales/en.json"
}

teardown() {
    rm -rf tmp
    rm -f "$CONFIG_FILE"
}

@test "with parameter | locale file exists" {
    run bash "$COMMON_PATH/check_locale_files.sh" "en"
    [ "$status" -eq 0 ]
}

@test "with parameter | locale file does not exist" {
    run bash "$COMMON_PATH/check_locale_files.sh" "hu"
    [ "$status" -eq 1 ]
    echo "$output" | grep -q "❌ Error: Missing locale file: tmp/locales/hu.json"
}

@test "without parameter | all locale files exist" {
    echo '{}' > "tmp/locales/hu.json"
    run bash "$COMMON_PATH/check_locale_files.sh"
    [ "$status" -eq 0 ]
}

@test "without parameter | a locale file is missing" {
    rm -f "tmp/locales/en.json"
    run bash "$COMMON_PATH/check_locale_files.sh"
    [ "$status" -eq 1 ]
    echo "$output" | grep -q "❌ Error: Missing locale file: tmp/locales/en.json"
}
