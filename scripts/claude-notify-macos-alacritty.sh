#!/bin/bash
# claude-notify.sh — sends macOS notification when Claude Code needs input
# Clicking the notification activates Alacritty and switches to the correct tmux window

TMUX_SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}')
TMUX_WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#{window_index}')

# Run in subshell & background so it doesn't block the hook
(
  RESULT=$(alerter \
    --title "Claude Code" \
    --message "Waiting for input in $TMUX_SESSION:$TMUX_WINDOW" \
    --sender org.alacritty \
    --sound default \
    --group "claude-$TMUX_SESSION-$TMUX_WINDOW" \
    --timeout 30)

  # If user clicked (not timeout/close), activate Alacritty and switch tmux session/window
  if [ "$RESULT" != "@TIMEOUT" ] && [ "$RESULT" != "@CLOSED" ]; then
    open -a Alacritty
    tmux switch-client -t "$TMUX_SESSION:$TMUX_WINDOW"
  fi
) &

