#!/usr/bin/env bash
# Publishes Claude's state as a tmux window option (@claude_state); tmux.conf
# maps it to a tab colour. State is per window: two Claudes in one window share it.
[ -n "$TMUX_PANE" ] || exit 0

input=$(cat)
field() { jq -r ".$1 // empty" <<<"$input"; }

case $(field hook_event_name) in
  SessionEnd)
    exec tmux set -wu -t "$TMUX_PANE" @claude_state ;;
  UserPromptSubmit | PostToolUse | PostToolUseFailure)
    state=running ;;
  PreToolUse) # settings.json limits this to tools that wait on the user
    state=input ;;
  PermissionRequest)
    case $(field tool_name) in
      AskUserQuestion | ExitPlanMode) state=input ;;
      *) state=blocked ;;
    esac ;;
  Notification)
    case $(field notification_type) in
      permission_prompt) state=blocked ;;
      *) state=input ;;
    esac ;;
  StopFailure)
    state=blocked ;;
  Stop)
    # ponytail: a trailing "?" is the only signal for a plain-text question; a
    # rhetorical ending reads yellow, a question mid-message reads green.
    msg=$(field last_assistant_message)
    if [[ ${msg%"${msg##*[![:space:]]}"} == *\? ]]; then state=input; else state=done; fi ;;
  *)
    exit 0 ;;
esac

tmux set -w -t "$TMUX_PANE" @claude_state "$state"
