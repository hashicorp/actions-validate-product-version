#!/usr/bin/env bats

# Need 1.5.0 for run() to accept flags
# Note: need 1.7.0 for bats_require_minimum_version definition.
bats_require_minimum_version 1.5.0

# Loading utils.bash will replace function `run` defined by bats.
# Rename bats' `run` function as `bats_run`.
# This must be in the current shell, so it cannot be within a bats setup* function.
eval "$(echo -n 'bats_run()' ; declare -f run | tail -n +2)"

setup_file() {
    export TD_DIR="${BATS_TEST_DIRNAME}/testdata"
}

#setup() { env | grep BATS | sort ; }

@test "required env vars" {
    source test-versions

    bats_run -1 -- ckvars
    [[ "$output" =~ 'ARTIFACT env var must be set' ]]

    ARTIFACT=/tmp
    bats_run -1 -- ckvars
    [[ "$output" =~ 'EXP_VERSION env var must be set' ]]

    EXP_VERSION='v1.2.3'
    bats_run -- ckvars
}

@test "munge_version_str" {
    source test-versions

    [ "$(printf "1.2.3" | munge_version_str)" = '1.2.3' ]
    [ "$(printf "1.2.3\n" | munge_version_str)" = "1.2.3${REPL_CHAR}" ]
    [ "$(printf "1.2.3-dev~1_1+ent.abc.123\n" | munge_version_str)" = "1.2.3-dev~1_1+ent.abc.123${REPL_CHAR}" ]
    [ "$(printf "1.2.3-dev\n+ent\n" | munge_version_str)" = "1.2.3-dev${REPL_CHAR}+ent${REPL_CHAR}" ]
}

@test "plain_executable_subcommand" {
    tool_name="test_tool_plain_executable"

    source test-versions
    export ARTIFACT="${TD_DIR}/${tool_name}" EXP_VERSION="1.2.3"
    cd "$BATS_TEST_TMPDIR"

    bats_run --separate-stderr -- test_artifact "$EXP_VERSION" "$ARTIFACT"
}

@test "plain_executable_dash_parameter" {
    tool_name="test_tool_plain_executable-version"

    source test-versions
    export ARTIFACT="${TD_DIR}/${tool_name}" EXP_VERSION="1.2.5"
    cd "$BATS_TEST_TMPDIR"

    bats_run --separate-stderr -- test_artifact "$EXP_VERSION" "$ARTIFACT"
}

@test "plain_executable_dashdash_parameter" {
    tool_name="test_tool_plain_executable--version"

    source test-versions
    export ARTIFACT="${TD_DIR}/${tool_name}" EXP_VERSION="1.2.4"
    cd "$BATS_TEST_TMPDIR"

    bats_run --separate-stderr -- test_artifact "$EXP_VERSION" "$ARTIFACT"
}

@test "zip_artifact" {
    tool_name="test_tool_from_zip"

    source test-versions
    export ARTIFACT="${TD_DIR}/${tool_name}.zip" EXP_VERSION="1.0.0"
    cd "$BATS_TEST_TMPDIR"

    bats_run --separate-stderr -- test_artifact "$EXP_VERSION" "$ARTIFACT"
}

@test "artifacts" {
    source test-versions
    export ARTIFACT="${TD_DIR}/artifacts"  EXP_VERSION="1.0.2+ent"
    cd "$BATS_TEST_TMPDIR"

    bats_run --separate-stderr -- main
}

@test "extra_trailing_newline" {
    source test-versions
    export ARTIFACT="${TD_DIR}/extra_trailing_newline" EXP_VERSION="1.1.1"
    cd "$BATS_TEST_TMPDIR"

    bats_run --separate-stderr -1 -- main
}

@test "newline_before_metadata" {
    source test-versions
    export ARTIFACT="${TD_DIR}/newline_before_metadata" EXP_VERSION="0.5.0+ent"
    cd "$BATS_TEST_TMPDIR"

    bats_run --separate-stderr -1 -- main
}
