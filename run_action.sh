#!/bin/zsh

if [[ ViolinJAX.js -ot ViolinJAX.coffee ]]; then
    coffee -b -s -p < ViolinJAX.coffee >| ViolinJAX.js
fi

ACTION=nextclip

if [[ $# -gt 0 ]]; then
    ACTION=$1
    shift
fi

osascript="osascript -l JavaScript ViolinJAX.js --$ACTION $*"

if [[ -n "$TMUX" ]]; then
    ${=osascript}
else
    cmd=(/opt/local/bin/tmux send-keys -t 0:0 "${osascript}" "C-M")
    if ! ${cmd}; then
        echo "Need to start tmux"
    fi
fi

