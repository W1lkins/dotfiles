#!/bin/bash

# Make sure we're in our dotfiles directory
cd /home/$USER/dotfiles

# Get all files/directories inside of the current directory that are hidden
dotFiles=`pwd`/.*

# Create a symlink in the current directory for all files/dirs inside of the dotfiles directory
for dotfile in $dotFiles
do
    ls $dotfile
    #ln -s $dotfile ../`basename $dotfile`
done
