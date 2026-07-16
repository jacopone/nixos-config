# Own-dogfooding of the company paid-API iron rules for ANTHROPIC spend — the
# company's largest paid API. Origin: 2026-07-14, the org's monthly cap was hit
# mid-task with zero early warning (subagents died, the auto-mode permission
# classifier blocked all writes, CI claude-review shared the same pool).
#
# Every 6h: sum month-to-date estimated cost from the Claude Code Analytics API
# (/v1/organizations/usage_report/claude_code — covers BOTH subscription and
# api actors, per-day, USD cents) plus the Console cost report
# (/v1/organizations/cost_report — API-key spend, e.g. CI review). Alert via
# notify-send + journal on 50/80/95% budget crossings. The two pools can
# overlap (claude_code api-actors also appear in cost_report) — deliberately
# errs toward alerting EARLY; this is a tripwire, not accounting.
#
# Config (manual, secrets never in git — invariant #8):
#   ~/.config/anthropic/admin-api-key       Admin API key (sk-ant-admin01-...), chmod 600
#   ~/.config/anthropic/monthly-budget-usd  plain number, e.g. 300
# No-ops with a journal hint until both exist.
{ lib, pkgs, ... }:

let
  alertScript = pkgs.writeShellScript "anthropic-usage-alert" ''
    set -u
    KEYF="$HOME/.config/anthropic/admin-api-key"
    BUDF="$HOME/.config/anthropic/monthly-budget-usd"
    STATE="$HOME/.claude/.anthropic-usage-alert.state"
    if [ ! -r "$KEYF" ] || [ ! -r "$BUDF" ]; then
      echo "anthropic-usage-alert: not configured (need $KEYF + $BUDF) — skipping"
      exit 0
    fi
    KEY="$(cat "$KEYF")"
    BUDGET="$(cat "$BUDF")"
    case "$BUDGET" in "" | *[!0-9.]*) echo "anthropic-usage-alert: budget file must be a plain number"; exit 0 ;; esac

    MONTH="$(date -u +%Y-%m)"
    TODAY="$(date -u +%F)"
    TOTAL_CENTS=0

    # Claude Code analytics: one call per day of the month (short burst — allowed
    # per API FAQ; sustained polling stays 4x/day via the timer)
    d="$MONTH-01"
    while [ "$(date -ud "$d" +%s)" -le "$(date -ud "$TODAY" +%s)" ]; do
      page=""
      while :; do
        url="https://api.anthropic.com/v1/organizations/usage_report/claude_code?starting_at=$d&limit=1000''${page:+&page=$page}"
        resp="$(curl -sf --max-time 30 -H "anthropic-version: 2023-06-01" -H "x-api-key: $KEY" "$url")" || { echo "anthropic-usage-alert: claude_code fetch failed for $d (continuing)"; break; }
        c="$(printf '%s' "$resp" | jq '[.data[].model_breakdown[]?.estimated_cost.amount // 0] | add // 0')"
        TOTAL_CENTS="$(awk "BEGIN{printf \"%.0f\", $TOTAL_CENTS + ''${c:-0}}")"
        hm="$(printf '%s' "$resp" | jq -r '.has_more // false')"
        page="$(printf '%s' "$resp" | jq -r '.next_page // empty')"
        { [ "$hm" = "true" ] && [ -n "$page" ]; } || break
      done
      d="$(date -ud "$d +1 day" +%F)"
    done

    # Console org API spend; tolerate 4xx (subscription-only orgs have none)
    cr_resp="$(curl -s --max-time 30 -H "anthropic-version: 2023-06-01" -H "x-api-key: $KEY" \
      "https://api.anthropic.com/v1/organizations/cost_report?starting_at=''${MONTH}-01T00:00:00Z&ending_at=$(date -ud "$TODAY +1 day" +%F)T00:00:00Z")" || cr_resp=""
    cr="$(printf '%s' "$cr_resp" | jq '[.. | objects | .amount? // empty | tonumber? // empty] | add // 0' 2>/dev/null || echo 0)"
    TOTAL_CENTS="$(awk "BEGIN{printf \"%.0f\", $TOTAL_CENTS + ''${cr:-0}}")"

    USD="$(awk "BEGIN{printf \"%.2f\", $TOTAL_CENTS/100}")"
    PCT="$(awk "BEGIN{printf \"%d\", ($TOTAL_CENTS/100)*100/$BUDGET}")"
    echo "anthropic-usage-alert: MTD ~\$$USD of \$$BUDGET ($PCT%)"

    TIER=0
    [ "$PCT" -ge 50 ] && TIER=50
    [ "$PCT" -ge 80 ] && TIER=80
    [ "$PCT" -ge 95 ] && TIER=95
    LTIER=0
    LMONTH=""
    if [ -f "$STATE" ]; then
      LTIER="$(cut -d: -f1 "$STATE")"
      LMONTH="$(cut -d: -f2 "$STATE")"
    fi
    [ "$LMONTH" = "$MONTH" ] || LTIER=0
    if [ "$TIER" -gt "''${LTIER:-0}" ]; then
      msg="Anthropic spend MTD ~\$$USD = $PCT% of \$$BUDGET budget (crossed $TIER%). See company policy: Anthropic Spend & Degraded Mode."
      command -v notify-send >/dev/null 2>&1 && notify-send -u critical "Anthropic usage alert" "$msg" || true
      echo "ALERT: $msg"
    fi
    printf '%s:%s\n' "$TIER" "$MONTH" > "$STATE"
  '';
in
{
  systemd.user.services.anthropic-usage-alert = {
    Unit.Description = "Anthropic month-to-date spend check vs budget";
    Service = {
      Type = "oneshot";
      ExecStart = "${alertScript}";
      Environment = "PATH=${lib.makeBinPath (with pkgs; [ bash coreutils curl jq gawk libnotify ])}";
    };
  };
  systemd.user.timers.anthropic-usage-alert = {
    Unit.Description = "Anthropic spend check every 6h";
    Timer = {
      OnCalendar = "00/6:40";
      Persistent = true;
      RandomizedDelaySec = "10m";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
