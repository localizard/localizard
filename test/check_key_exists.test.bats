#!/usr/bin/env bats

COMMON_PATH="$(cd -- "$(dirname "${BATS_TEST_FILENAME}")/../common" >/dev/null 2>&1 && pwd)"
source "$COMMON_PATH/constants.sh"

setup_file() {
    mkdir -p tmp
    echo '{"TEST": "test"}' > "tmp/en.json"
}

teardown_file() {
    rm -rf tmp
}

@test "key exists" {
    run bash "$COMMON_PATH/check_key_exists.sh" "tmp/en.json" "TEST"
    [ "$status" -eq 0 ]
}

@test "key does not exist" {
    run bash "$COMMON_PATH/check_key_exists.sh" "tmp/en.json" "NOT_EXISTS"
    [ "$status" -eq 1 ]
}