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
