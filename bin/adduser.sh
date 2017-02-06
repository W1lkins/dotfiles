#!/bin/bash
# Script to add a user to Linux system
if [ "$(id -u)" -eq 0 ]; then
    read -p "enter username : " username
    read -s -p "enter password : " password
    egrep "^$username" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        echo -e "\n$username already exists"
        exit 1
    else
        pass=$(perl -e 'print crypt($ARGV[0], "password")' "$password")
        useradd -m -p "$pass" "$username"
        [ $? -eq 0 ] && echo -e "\nUser successfully added" || echo -e "\nFailed to add user"
    fi
else
    echo "script must be run as root"
    exit 2
fi
