#!/usr/bin/env bash
# PreToolUse(Bash): deny `git commit` in a repo that has `make check` unless the gate
# passed on this exact tree. Run ~/.claude/hooks/gate in the repo to pass it.
# ponytail: each commit's repo is found from `git -C <dir>` or the last `cd <dir>` before it,
# else the session cwd; a repo named by a shell expansion is denied. A commit run from a script,
# alias or subshell elsewhere is not seen.
set -uo pipefail
here=$(dirname "$(readlink -f "$0")")
input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
# Find a `git ... commit` in any segment of the command line: skip git's global options
# (-c k=v, -C dir, --git-dir=...) and read the first real word as the subcommand.
dirs=(); last_cd=""
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
    if [ "${words[j]:-}" = commit ]; then dirs+=("${gdir:-${last_cd:-.}}"); fi
  done
done < <(tr ';&|' '\n\n\n' <<<"$cmd")
[ ${#dirs[@]} -gt 0 ] || exit 0
cwd=$(jq -r '.cwd // empty' <<<"$input")

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
  exit 0
}

for dir in "${dirs[@]}"; do
  case $dir in
    *'$'*|*'`'*) deny "Commit blocked: the repo is named by a shell expansion ($dir), so the gate cannot tell which tree is committed. Commit with a literal path (git -C /path commit ...), one command per repo after its gate." ;;
  esac
  [ "$dir" = . ] && dir=$cwd
  case $dir in /*|'~'*) ;; *) dir="$cwd/$dir" ;; esac
  dir=${dir/#\~/$HOME}
  dir=${dir//\"/}
  [ -d "$dir" ] || continue
  repo=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || continue
  grep -qE '^check:' "$repo/Makefile" 2>/dev/null || continue
  stamp="$(git -C "$repo" rev-parse --git-dir)"
  case $stamp in /*) ;; *) stamp="$repo/$stamp" ;; esac
  stamp="$stamp/gate-pass"
  now=$(cd "$repo" && "$here/gate-fingerprint")
  [ -f "$stamp" ] && [ "$(cat "$stamp")" = "$now" ] && continue
  deny "Commit blocked: make check has not passed on this exact tree in $repo. Run '~/.claude/hooks/gate' there as its own command (it runs make check and stamps the tree), then commit in the next command. Any edit after the gate needs the gate again."
done
exit 0
