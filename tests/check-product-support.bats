#!/usr/bin/env bats

# Need 1.5.0 for run() to accept flags
# Note: need 1.7.0 for bats_require_minimum_version definition.
bats_require_minimum_version 1.5.0

# Loading utils.bash will replace function `run` defined by bats.
# Rename bats' `run` function as `bats_run`.
# This must be in the current shell, so it cannot be within a bats setup* function.
eval "$(echo -n 'bats_run()' ; declare -f run | tail -n +2)"

setup() {
    source check-product-support
}

@test "tool supported" {
    bats_run --separate-stderr -- check consul
    [ "$output" = 'true' ]
}

@test "tool.zip supported" {
    bats_run --separate-stderr -- check consul_1.2.3_darwin_arm64.zip
    [ "$output" = 'true' ]
}

@test "tool unsupported" {
    bats_run --separate-stderr -- check no-such-tool
    [ "$output" != 'true' ]
}

@test "directory of artifacts: unsupported" {
    bats_run --separate-stderr -- main "tests/testdata/support/unsupported"
    [ "$output" != 'true' ]
}

@test "directory of artifacts: supported" {
    bats_run --separate-stderr -- main "tests/testdata/support/supported"
    [ "$output" != 'false' ]
}
