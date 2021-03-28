#!/bin/sh 
# Opens a cmus in tmux session

tmux new -s MUSIC "cmus" || tmux attach -t MUSIC
