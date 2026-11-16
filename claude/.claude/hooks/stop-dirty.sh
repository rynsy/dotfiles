#!/usr/bin/env bash
# Stop: refuse to end the turn while files changed during this session sit uncommitted in an
# agent worktree (~/worktrees) or in the vault's agent folders. A second stop in a row is
# allowed, so a reply that says why the changes stay uncommitted can end the turn.
# ponytail: "changed this session" = modified after the transcript file was created;
# deletions are not seen (no mtime).
set -uo pipefail
input=$(cat)
[ "$(jq -r '.stop_hook_active // false' <<<"$input")" = true ] && exit 0
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
start=0
[ -n "$transcript" ] && [ -f "$transcript" ] && start=$(stat -c %W "$transcript" 2>/dev/null || echo 0)
[ "$start" -gt 0 ] 2>/dev/null || start=$(( $(date +%s) - 12 * 3600 ))

dirty=()
check_repo() {
  local repo=$1 prefix=$2 path
  while IFS= read -r line; do
    path=${line:3}; path=${path##* -> }; path=${path//\"/}
    [ -n "$prefix" ] && ! grep -qE "^($prefix)" <<<"$path" && continue
    [ -e "$repo/$path" ] || continue
    [ "$(stat -c %Y "$repo/$path")" -ge "$start" ] && dirty+=("$repo/$path")
  done < <(git -C "$repo" status --porcelain 2>/dev/null)
}
for g in "$HOME"/worktrees/*/.git "$HOME"/worktrees/*/*/.git "$HOME"/worktrees/*/*/*/.git; do
  [ -e "$g" ] && check_repo "$(dirname "$g")" ""
done
[ -d "$HOME/journal/.git" ] && check_repo "$HOME/journal" "raw/|workstreams/|runbooks/|wiki/|scripts/|AGENTS.md"

[ ${#dirty[@]} -eq 0 ] && exit 0
list=$(printf '%s\n' "${dirty[@]}" | head -20)
reason="Uncommitted changes from this session:
$list
Commit them (run ~/.claude/hooks/gate first where the repo has make check), or say in your reply why they stay uncommitted."
jq -n --arg r "$reason" '{decision: "block", reason: $r}'
