#!/bin/bash

# Make sure we're in our home directory
cd /home/$USER/

# Make * match ALL files, including hidden files
shopt -s dotglob

# Get all files/directories inside of the dotfiles directory
dotFiles=`pwd`/dotfiles/*

# Create a symlink in the current directory for all files/dirs inside of the dotfiles directory
for dotfile in $dotFiles
do
    ln -s $dotfile ./`basename $dotfile`
done
