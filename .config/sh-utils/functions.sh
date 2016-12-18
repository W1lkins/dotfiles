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
