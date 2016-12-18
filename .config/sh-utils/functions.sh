# make a note with an argv filename, else note_$(time)
makenote() {
    if [ $# -eq 0 ]
    then
        local filename=note_`date +%H%M%S`
        touch $filename
        vi $filename
    else
        touch $1
        vi $1
    fi
}

# htop current user, else htop 1st argv
utop() {
    if [ $# -eq 0 ]
    then
        htop -u $USER
    else
        htop -u $1
    fi
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
