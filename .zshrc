#!/bin/bash

# source all the files in .config
for file in "$HOME/.config/sh-utils"/*
do
    source "$file"
done
