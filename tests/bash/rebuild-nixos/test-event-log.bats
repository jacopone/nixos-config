#!/usr/bin/env bats
# Unit test for rebuild-nixos's log_event / step / step_done / step_skip
# event emission. Sources just those helpers into a test harness instead of
# invoking ./rebuild-nixos directly (rebuild-nixos requires sudo and mutates
# the live system — wrong tool for a unit test).
#
# Spec: docs/plans/2026-05-18-agent-view-pilot-task.md
# Source: P1-1 of docs/plans/2026-05-18-claude-code-advancements-audit.md

PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../" && pwd)"
REBUILD_SCRIPT="$PROJECT_ROOT/rebuild-nixos"

# Source the event-log helpers directly from lib/event-log.sh — the same file
# rebuild-nixos sources. No line-range extraction, so the test cannot drift
# from the live helpers (a rename or re-indent now fails loudly at source time
# instead of silently capturing the wrong range).
#
# TOTAL_STEPS is caller-provided (rebuild-nixos computes it; here it is pinned
# to 3 so the step-counter assertions are deterministic). CURRENT_STEP is
# initialized by the lib. BLUE/NC are left unset — step() prints uncolored.
setup() {
    EVENT_TMPDIR=$(mktemp -d)
    export HOME="$EVENT_TMPDIR"
    export EVENT_LOG_DIR="$HOME/.local/state/rebuild-nixos"
    export EVENT_LOG="$EVENT_LOG_DIR/events.jsonl"
    export LAST_STATUS_FILE="$EVENT_LOG_DIR/last-status"
    export TOTAL_STEPS=3

    # shellcheck source=../../../lib/event-log.sh
    source "$PROJECT_ROOT/lib/event-log.sh"
}

teardown() {
    rm -rf "$EVENT_TMPDIR"
}

@test "log_event writes JSONL output" {
    log_event start phase_a
    [ -f "$EVENT_LOG" ]
}

@test "log_event output is valid JSON" {
    log_event start phase_a
    run jq -e . "$EVENT_LOG"
    [ "$status" -eq 0 ]
}

@test "log_event output has required ts phase event fields" {
    log_event start phase_a
    run jq -e 'has("ts") and has("phase") and has("event")' "$EVENT_LOG"
    [ "$status" -eq 0 ]
}

@test "log_event phase field matches input" {
    log_event start phase_test
    result=$(jq -r .phase "$EVENT_LOG")
    [ "$result" = "phase_test" ]
}

@test "log_event event field matches input" {
    log_event start phase_test
    result=$(jq -r .event "$EVENT_LOG")
    [ "$result" = "start" ]
}

@test "log_event ts field is non-empty" {
    log_event start phase_test
    result=$(jq -r .ts "$EVENT_LOG")
    [ -n "$result" ]
    [ "$result" != "null" ]
}

@test "log_event merges extras into output" {
    log_event complete phase_b '{"duration_ms":1234,"step":2}'
    dur=$(jq -r .duration_ms "$EVENT_LOG")
    step=$(jq -r .step "$EVENT_LOG")
    [ "$dur" = "1234" ]
    [ "$step" = "2" ]
}

@test "step emits start event with phase name" {
    step "Building configuration"
    result=$(jq -r .phase "$EVENT_LOG")
    [ "$result" = "Building configuration" ]
}

@test "step emits start event with step counter" {
    step "Building configuration"
    result=$(jq -r .step "$EVENT_LOG")
    [ "$result" = "1" ]
}

@test "step emits start event with total_steps" {
    step "Building configuration"
    result=$(jq -r .total_steps "$EVENT_LOG")
    [ "$result" = "3" ]
}

@test "consecutive step calls close previous phase with complete event" {
    step "Phase one"
    step "Phase two"
    line_count=$(wc -l < "$EVENT_LOG")
    [ "$line_count" -eq 3 ]
    complete_phase=$(jq -r -c 'select(.event == "complete") | .phase' "$EVENT_LOG")
    [ "$complete_phase" = "Phase one" ]
}

@test "complete event includes duration_ms" {
    step "Phase one"
    step "Phase two"
    dur=$(jq -r -c 'select(.event == "complete") | .duration_ms' "$EVENT_LOG")
    [ -n "$dur" ]
    [ "$dur" != "null" ]
}

@test "step_done emits final complete event for active phase" {
    step "Final phase"
    step_done
    last_event=$(tail -1 "$EVENT_LOG" | jq -r .event)
    last_phase=$(tail -1 "$EVENT_LOG" | jq -r .phase)
    [ "$last_event" = "complete" ]
    [ "$last_phase" = "Final phase" ]
}

@test "step_done is idempotent when no phase active" {
    step_done
    [ ! -s "$EVENT_LOG" ]
}

@test "step_skip emits skip event" {
    step_skip "Phase X" business_host
    result=$(tail -1 "$EVENT_LOG" | jq -r .event)
    [ "$result" = "skip" ]
}

@test "step_skip records phase name" {
    step_skip "Phase X" business_host
    result=$(tail -1 "$EVENT_LOG" | jq -r .phase)
    [ "$result" = "Phase X" ]
}

@test "step_skip records skip reason" {
    step_skip "Phase X" business_host
    result=$(tail -1 "$EVENT_LOG" | jq -r .reason)
    [ "$result" = "business_host" ]
}

@test "write_last_status writes succ value" {
    write_last_status succ
    result=$(cat "$LAST_STATUS_FILE")
    [ "$result" = "succ" ]
}

@test "write_last_status writes fail value" {
    write_last_status fail
    result=$(cat "$LAST_STATUS_FILE")
    [ "$result" = "fail" ]
}

@test "multi-phase event sequence produces only valid JSON objects" {
    step "A"
    step "B"
    step_done
    step_skip "C" quick_mode
    log_event fail "D" '{"exit_code":1}'

    run jq -se 'all(type == "object")' "$EVENT_LOG"
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

@test "all events in a sequence have required fields" {
    step "A"
    step "B"
    step_done
    step_skip "C" quick_mode

    run jq -se 'all(has("ts") and has("phase") and has("event"))' "$EVENT_LOG"
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

@test "EVENT_LOG_DIR is created idempotently" {
    rm -rf "$EVENT_LOG_DIR"
    # shellcheck source=../../../lib/event-log.sh
    source "$PROJECT_ROOT/lib/event-log.sh"
    [ -d "$EVENT_LOG_DIR" ]
}

@test "log_event falls back gracefully on invalid extras JSON" {
    log_event start phase_bad not-json-at-all
    [ -f "$EVENT_LOG" ]
    run jq -e 'has("ts") and has("phase") and has("event")' "$EVENT_LOG"
    [ "$status" -eq 0 ]
}

@test "lib/event-log.sh defines log_event function" {
    grep -q '^log_event()' "$PROJECT_ROOT/lib/event-log.sh"
}

@test "lib/event-log.sh defines step_done function" {
    grep -q '^step_done()' "$PROJECT_ROOT/lib/event-log.sh"
}

@test "lib/event-log.sh defines step_skip function" {
    grep -q '^step_skip()' "$PROJECT_ROOT/lib/event-log.sh"
}

@test "rebuild-nixos sources lib/event-log.sh" {
    grep -q 'source.*lib/event-log.sh' "$REBUILD_SCRIPT"
}

@test "rebuild-nixos cleanup trap writes fail to last-status" {
    grep -q 'write_last_status fail' "$REBUILD_SCRIPT"
}

@test "rebuild-nixos success path writes succ to last-status" {
    grep -q 'write_last_status succ' "$REBUILD_SCRIPT"
}
