#!/bin/bash
current_session=$(tmux display-message -p '#S')

# catppuccinテーマカラーをtmuxオプションから取得
active_bg=$(tmux show-option -gqv @thm_mauve)
active_fg=$(tmux show-option -gqv @thm_crust)
inactive_bg=$(tmux show-option -gqv @thm_surface_0)
inactive_fg=$(tmux show-option -gqv @thm_overlay_2)

tmux list-sessions -F '#S' | while read -r session; do
  if [ "$session" = "$current_session" ]; then
    printf '#[bg=%s,fg=%s,bold] %s #[default] ' "$active_bg" "$active_fg" "$session"
  else
    printf '#[bg=%s,fg=%s] %s #[default] ' "$inactive_bg" "$inactive_fg" "$session"
  fi
done
