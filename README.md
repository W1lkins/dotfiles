```
              ▄▄                         ▄▄▄▄      ██     ▄▄▄▄                         
              ██              ██        ██▀▀▀      ▀▀     ▀▀██                         
         ▄███▄██   ▄████▄   ███████   ███████    ████       ██       ▄████▄   ▄▄█████▄ 
        ██▀  ▀██  ██▀  ▀██    ██        ██         ██       ██      ██▄▄▄▄██  ██▄▄▄▄ ▀ 
        ██    ██  ██    ██    ██        ██         ██       ██      ██▀▀▀▀▀▀   ▀▀▀▀██▄ 
        ▀██▄▄███  ▀██▄▄██▀    ██▄▄▄     ██      ▄▄▄██▄▄▄    ██▄▄▄   ▀██▄▄▄▄█  █▄▄▄▄▄██ 
          ▀▀▀ ▀▀    ▀▀▀▀       ▀▀▀▀     ▀▀      ▀▀▀▀▀▀▀▀     ▀▀▀▀     ▀▀▀▀▀    ▀▀▀▀▀▀  
```

[![Build Status](https://travis-ci.org/W1lkins/dotfiles.svg?branch=master)](https://travis-ci.org/W1lkins/dotfiles)
<br>

## What's included?

- compton
- dmenu
- git config
- htoprc
- inputrc
- macOS sane defaults & brew
- ncmpcpp
- neovim
- polybar
- ranger
- redshift
- screenlayouts for monitors
- suckless-terminal
- tmux
- vim
- vim colorschemes & plugins
- xinitrc which starts i3
- xmodmap for gb keyboard layout
- xresources
- yay (aur)
- zsh

---

## Installation

**Clone the repository**:

- `git clone https://github.com/w1lkins/dotfiles dotfiles && cd $_`

**Install**

*_requires Golang - alternatively download a release from from: [here](https://github.com/W1lkins/dotfiles/releases)_

- `make`

You will be asked about gpg keys for git (defaults to no) and whether you want
to backup your existing dotfiles (defaults to skip)

**Finally, run**:

`source ~/.zshrc`

---

## Trying without installing

**Clone the repository**:

- `git clone https://github.com/w1lkins/dotfiles && cd dotfiles`

**Run Makefile command**:

- `make docker`

