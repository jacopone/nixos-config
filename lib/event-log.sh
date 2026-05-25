# shellcheck shell=bash
# Structured event log + step helpers for rebuild-nixos.
#
# SOURCED, never executed. Two callers:
#   - ./rebuild-nixos sources this early (before the cleanup trap is installed)
#     so the trap can emit fail events / write last-status if the script aborts
#     during argument parsing or setup.
#   - tests/bash/rebuild-nixos/test-event-log.bats sources it directly, so the
#     tested helpers never drift from a brittle line-range extraction.
#
# step() references caller-provided BLUE, NC, TOTAL_STEPS at CALL time, not at
# source time: rebuild-nixos defines all three before its first step() call; the
# test sets TOTAL_STEPS and leaves BLUE/NC empty (uncolored output).
#
# No `set -e`/`set -o pipefail` here — sourcing must not pollute the caller's
# shell options. No shebang — this file is not an executable.

# Structured event log + statusline status file.
# Initialized early so the cleanup trap can emit fail events / write status
# even if the script aborts during argument parsing or setup.
# Consumed by P1-2 (telemetry MCP) and statusline.sh.
# Defaulted via parameter expansion so a caller (the test) can pre-set them.
EVENT_LOG_DIR="${EVENT_LOG_DIR:-$HOME/.local/state/rebuild-nixos}"
EVENT_LOG="${EVENT_LOG:-$EVENT_LOG_DIR/events.jsonl}"
# Two sinks by design: EVENT_LOG is the append-only JSONL history (every event;
# consumed by the P1-2 telemetry MCP). LAST_STATUS_FILE is a single overwritten
# word (succ/fail) so statusline.sh — which renders on every prompt — reads the
# last outcome in O(1) without tailing and parsing a growing JSONL.
LAST_STATUS_FILE="${LAST_STATUS_FILE:-$EVENT_LOG_DIR/last-status}"
mkdir -p "$EVENT_LOG_DIR" 2>/dev/null || true

# log_event TYPE PHASE [EXTRAS_JSON]
# Emits a single JSONL record to $EVENT_LOG.
# EXTRAS_JSON, if given, must be a valid JSON object string (merged into the event).
# MUST NOT fail under set -e -o pipefail — wrapped in || true and falls back
# to printf if jq is missing or returns non-zero (e.g., malformed extras).
# shellcheck disable=SC2329  # invoked from trap
log_event() {
    local event_type="$1"
    local phase="$2"
    local extras="${3:-{\}}"
    local ts
    ts=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)

    if command -v jq >/dev/null 2>&1; then
        jq -cn \
            --arg ts "$ts" \
            --arg phase "$phase" \
            --arg event "$event_type" \
            --argjson extras "$extras" \
            '{ts: $ts, phase: $phase, event: $event} + $extras' \
            >> "$EVENT_LOG" 2>/dev/null \
            || printf '{"ts":"%s","phase":"%s","event":"%s"}\n' "$ts" "$phase" "$event_type" >> "$EVENT_LOG" 2>/dev/null \
            || true
    else
        # Fallback: hand-rolled JSON (no extras merge — keeps schema valid)
        printf '{"ts":"%s","phase":"%s","event":"%s"}\n' "$ts" "$phase" "$event_type" >> "$EVENT_LOG" 2>/dev/null || true
    fi
}

# write_last_status STATUS
# Writes a one-word status (succ/fail) consumed by statusline.sh.
# Best-effort: never fails the parent script.
# shellcheck disable=SC2329  # invoked from trap
write_last_status() {
    printf '%s' "$1" > "$LAST_STATUS_FILE" 2>/dev/null || true
}

# Tracks the currently-running phase so cleanup() can attribute failures
# and step()/step_complete can compute duration_ms.
CURRENT_PHASE_NAME=""
CURRENT_PHASE_START_MS=""
# Step counter for the "Step X/Y" progress indicator. Owned here so the
# step()/step_complete helpers and their tests share a single initialization.
CURRENT_STEP=0

# Current epoch milliseconds (best-effort; falls back to seconds*1000).
# Wall-clock, NOT monotonic: a duration_ms computed as (now_ms - start) can go
# negative or inflate if the clock steps (NTP) or the host suspends mid-phase.
# Accepted — phase durations are coarse telemetry, not a precise timer.
now_ms() {
    if date +%s%3N 2>/dev/null | grep -qE '^[0-9]+$'; then
        date +%s%3N
    else
        printf '%s000' "$(date +%s)"
    fi
}

# Major step indicator with "Step X/Y" format
# Usage: step "Step description"
# Emits a JSONL "complete" event for the previously-active phase (if any),
# then a "start" event for the new phase. Duration is computed from
# CURRENT_PHASE_START_MS, in milliseconds.
step() {
    # Close out the previous phase if one was active
    if [ -n "$CURRENT_PHASE_NAME" ] && [ -n "$CURRENT_PHASE_START_MS" ]; then
        local _now_ms _dur_ms
        _now_ms=$(now_ms)
        _dur_ms=$((_now_ms - CURRENT_PHASE_START_MS))
        log_event complete "$CURRENT_PHASE_NAME" "{\"duration_ms\":$_dur_ms,\"step\":$CURRENT_STEP}"
    fi

    CURRENT_STEP=$((CURRENT_STEP + 1))
    local step_name="$1"
    CURRENT_PHASE_NAME="$step_name"
    CURRENT_PHASE_START_MS=$(now_ms)
    log_event start "$step_name" "{\"step\":$CURRENT_STEP,\"total_steps\":${TOTAL_STEPS:-0}}"
    echo ""
    echo -e "${BLUE}━━━ Step $CURRENT_STEP/$TOTAL_STEPS: $step_name ━━━${NC}"
}

# Close out the active phase with an explicit complete event. Use at script
# end so the final phase is captured (otherwise it'd dangle until a never-arriving
# next step()). Idempotent — safe to call when no phase is active.
step_complete() {
    if [ -n "$CURRENT_PHASE_NAME" ] && [ -n "$CURRENT_PHASE_START_MS" ]; then
        local _now_ms _dur_ms
        _now_ms=$(now_ms)
        _dur_ms=$((_now_ms - CURRENT_PHASE_START_MS))
        log_event complete "$CURRENT_PHASE_NAME" "{\"duration_ms\":$_dur_ms,\"step\":$CURRENT_STEP}"
        CURRENT_PHASE_NAME=""
        CURRENT_PHASE_START_MS=""
    fi
}

# Emit a skip event for a phase that didn't run (business-host gating,
# --quick mode, --dry-run, etc.) without flipping the active-phase trackers.
step_skip() {
    local phase="$1"
    local reason="${2:-unknown}"
    log_event skip "$phase" "{\"reason\":\"$reason\"}"
}
