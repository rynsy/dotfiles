#!/usr/bin/env bash
# Claude Code status line: model | branch | context used | session cost.
# Context % is null until the first response, so it is read last: tab-separated
# read collapses empty fields, and a trailing one can't shift the others.
IFS=$'\t' read -r model dir cost pct < <(jq -r '[
  .model.display_name, .workspace.current_dir, (.cost.total_cost_usd // 0),
  (.context_window.used_percentage // "")
] | @tsv')

sep=$'\033[38;5;245m | \033[0m'
line=$(printf '\033[38;5;183m%s\033[0m' "$model")

branch=$(git -C "$dir" branch --show-current 2>/dev/null)
[ -n "$branch" ] && line+=$sep$(printf '\033[38;5;111m%s\033[0m' "$branch")

if [ -n "$pct" ]; then
  pct=$(printf '%.0f' "$pct")
  if [ "$pct" -ge 80 ]; then color=211; elif [ "$pct" -ge 50 ]; then color=222; else color=114; fi
  line+=$sep$(printf '\033[38;5;%smctx %s%%\033[0m' "$color" "$pct")
fi

printf '%s%s$%.2f\n' "$line" "$sep" "$cost"
