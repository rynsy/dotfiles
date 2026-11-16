#!/usr/bin/env bash
# PreToolUse(Bash): deny `git commit` in a repo that has `make check` unless the gate
# passed on this exact tree. Run ~/.claude/hooks/gate in the repo to pass it.
# ponytail: the repo is found from `git -C <dir>` or the last `cd <dir>` before the commit,
# else the session cwd; a commit run from a script, alias or subshell elsewhere is not seen.
set -uo pipefail
here=$(dirname "$(readlink -f "$0")")
input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
# Find a `git ... commit` in any segment of the command line: skip git's global options
# (-c k=v, -C dir, --git-dir=...) and read the first real word as the subcommand.
dir=""; found=false; last_cd=""
while IFS= read -r segment; do
  read -ra words <<<"$segment"
  for ((i = 0; i < ${#words[@]}; i++)); do
    if [ "${words[i]}" = cd ] && [ $((i + 1)) -lt ${#words[@]} ]; then last_cd=${words[i+1]}; fi
    [ "${words[i]}" = git ] || continue
    gdir=""; j=$((i + 1))
    while [ $j -lt ${#words[@]} ]; do
      case ${words[j]} in
        -C) gdir=${words[j+1]:-}; j=$((j + 2)) ;;
        -c|--git-dir|--work-tree|--namespace) j=$((j + 2)) ;;
        -*) j=$((j + 1)) ;;
        *) break ;;
      esac
    done
    if [ "${words[j]:-}" = commit ]; then found=true; dir=${gdir:-$last_cd}; break 2; fi
  done
done < <(tr ';&|' '\n\n\n' <<<"$cmd")
$found || exit 0
[ -n "$dir" ] || dir=$(jq -r '.cwd // empty' <<<"$input")
dir=${dir/#\~/$HOME}
dir=${dir//\"/}
[ -d "$dir" ] || exit 0
repo=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
grep -qE '^check:' "$repo/Makefile" 2>/dev/null || exit 0

stamp="$(git -C "$repo" rev-parse --git-dir)"
case $stamp in /*) ;; *) stamp="$repo/$stamp" ;; esac
stamp="$stamp/gate-pass"
now=$(cd "$repo" && "$here/gate-fingerprint")
if [ -f "$stamp" ] && [ "$(cat "$stamp")" = "$now" ]; then
  exit 0
fi

reason="Commit blocked: make check has not passed on this exact tree in $repo. Run '~/.claude/hooks/gate' there as its own command (it runs make check and stamps the tree), then commit in the next command. Any edit after the gate needs the gate again."
jq -n --arg r "$reason" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
