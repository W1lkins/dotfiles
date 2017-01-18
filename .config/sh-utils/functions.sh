#!/bin/bash

# make a note with an argv filename, else note_$(time)
makenote() {
    if [ $# -eq 0 ]
    then
        local filename=note_$(date +%H%M%S)
        touch "$filename"
        vi "$filename"
    else
        touch "$1"
        vi "$1"
    fi
}

# htop current user, else htop 1st argv
utop() {
    if [ $# -eq 0 ]
    then
        htop -u "$USER"
    else
        htop -u "$1"
    fi
}

# disable crontab -r
function crontab() {
    # replace -r with -e
    /usr/bin/crontab "${@/-r/-e}"
}

# add current user to specified groups
joingroup() {
    for group in "$@"; do
        sudo gpasswd -a "$USER" "$group"
    done
}

# del user from specified groups
leavegroup() {
    for group in "$@"; do
        sudo gpasswd -d "$USER" "$group"
    done
}

# coloured man pages
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# search the aur for a pkg using cower
aursearch() {
    cower -s "$1"
}

# download from aur using cower to ~$USER/tmp
aurdl() {
    cd /home/"$USER"/tmp || exit;
    cower -d "$1"
}

# pull from git, add everything, and commit with first argv
gitshove() {
    gpull;
    ga;
    git commit -m "$1";
}

# create a tmux session with a name corresponding to 1st argv
tc() {
    tmux new -s "$1"
}

# attach to tmux session with name corresponding to 1st argv
ta() {
    tmux attach -t "$1"
}
