#!/bin/sh
# prints all scripts to fzf and than opens it in editor.

$EDITOR "$(find ~/.scripts/* | fzf)"
