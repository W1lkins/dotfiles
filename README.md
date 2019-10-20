```
     _       _    __ _ _           
  __| | ___ | |_ / _(_) | ___  ___ 
 / _` |/ _ \| __| |_| | |/ _ \/ __|
| (_| | (_) | |_|  _| | |  __/\__ \
 \__,_|\___/ \__|_| |_|_|\___||___/
```

## Includes

- 1password-cli
- [packages](packages)
- alacritty
- bat
- compton
- dmenu
- docker
- ffsend
- fonts
- fzf
- gdrive
- ghq
- git config
- go
- htoprc
- icdiff
- inputrc
- lsd
- magic-wormhole
- miniserve
- ncmpcpp
- oh-my-zsh
- pipenv
- polybar
- python3
- ranger
- redshift
- ripgrep
- rust
- screenlayouts for monitors
- shellharden
- staticcheck
- sudoers setup
- tmux
- xinitrc which starts i3
- xresources
- yapf
- yarn
- zsh

---

## Installation

- `git clone https://github.com/evalexpr/dotfiles dotfiles && cd $_`
- `make init` (you will be asked about gpg keys for git (defaults to no) and whether you want to backup your existing dotfiles (defaults to skip, which will make no changes)
- `source ~/.zshrc`

---

## Trying without installing

- `git clone https://github.com/evalexpr/dotfiles dotfiles && cd $_`
- `make docker`

