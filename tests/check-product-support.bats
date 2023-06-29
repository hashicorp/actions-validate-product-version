#!/usr/bin/env bats

# Need 1.5.0 for run() to accept flags
# Note: need 1.7.0 for bats_require_minimum_version definition.
bats_require_minimum_version 1.5.0

# Loading utils.bash will replace function `run` defined by bats.
# Rename bats' `run` function as `bats_run`.
# This must be in the current shell, so it cannot be within a bats setup* function.
eval "$(echo -n 'bats_run()' ; declare -f run | tail -n +2)"

@test "tool supported" {
    source check-product-support
    bats_run -- check consul
    [ "$output" = 'true' ]
}

@test "tool.zip supported" {
    source check-product-support
    bats_run -- check consul.zip
    [ "$output" = 'true' ]
}

@test "tool unsupported" {
    source check-product-support
    bats_run -- check no-such-tool
    [ "$output" != 'true' ]
}
