#!/bin/bash

# oh-my-zsh
source "$ZSH"/oh-my-zsh.sh

# base16 shell
export BASE16_SHELL="$HOME/.config/base16-shell/base16-ocean.dark.sh"
[[ -s $BASE16_SHELL ]] && source "$BASE16_SHELL"
