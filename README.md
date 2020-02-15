```
     _       _    __ _ _           
  __| | ___ | |_ / _(_) | ___  ___ 
 / _` |/ _ \| __| |_| | |/ _ \/ __|
| (_| | (_) | |_|  _| | |  __/\__ \
 \__,_|\___/ \__|_| |_|_|\___||___/
```

Uses a mixture of a bootstrapping script at install.sh and a [Brewfile](Brewfile) which uses [homebrew-bundle](https://github.com/Homebrew/homebrew-bundle.git) to install a list of packages.

Should work on both Linux and macOS.

---

## Installation

### Buyer beware: look at what you're installing first before doing this, some of this is custom to me only

- `git clone https://github.com/evalexpr/dotfiles dotfiles && cd $_`
- `make init`
- `source ~/.zshrc`

---

## Trying without installing

- `git clone https://github.com/evalexpr/dotfiles dotfiles && cd $_`
- `make docker`
