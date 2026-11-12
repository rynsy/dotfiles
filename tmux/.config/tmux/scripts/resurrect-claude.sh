#!/usr/bin/env bash
# tmux-resurrect post-save hook: rewrite each saved Claude pane's command to
# resume that pane's exact session (@claude_session, set by the Claude hook in
# ~/.claude/hooks/tmux-status.sh), so a bare `claude` comes back where it was.
# ponytail: other flags on the original command are dropped; carry them over if
# you start launching claude with options that matter on resume.
file=$1
awk -F'\t' -v OFS='\t' '
  NR == FNR { if ($4 != "") id[$1 FS $2 FS $3] = $4; next }
  $1 == "pane" && ($2 FS $3 FS $6) in id && $NF ~ /claude/ {
    split(substr($NF, 2), argv, " ")
    $NF = ":" argv[1] " --resume " id[$2 FS $3 FS $6]
  }
  1
' <(tmux list-panes -a -F '#{session_name}	#{window_index}	#{pane_index}	#{@claude_session}') "$file" >"$file.tmp" &&
  mv "$file.tmp" "$file"
