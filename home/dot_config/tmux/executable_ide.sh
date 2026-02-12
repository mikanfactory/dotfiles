#!/bin/bash
tmux split-window -h -p 80
tmux split-window -h -p 40
tmux split-window -v -p 40
tmux select-pane -t 0
