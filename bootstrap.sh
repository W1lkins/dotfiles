#!/bin/bash

DOTFILES_ROOT=$(pwd -P)
set -e
echo ''

# util functions
info () {
  printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] %s\n" "$1"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
  echo ''
  exit
}

setup_gitconfig () {
  if ! [ -f "$HOME/.gitconfig" ]
  then
    info 'setup gitconfig'

    git_credential='cache'
    if [ "$(uname -s)" == "Darwin" ]
    then
      git_credential='osxkeychain'
    fi

    user ' - What is your github author name?'
    read -re git_authorname
    user ' - What is your github author email?'
    read -re git_authoremail

    cp git/gitconfig ~/.gitconfig

    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" -i ~/.gitconfig

    success 'gitconfig'
  else
    success 'skipped gitconfig'
  fi
}


link_file () {
  local src=$1 dst=$2

  local overwrite=''
  local backup=''
  local skip=''
  local action=''

  if [ -f "$dst" ] || [ -d "$dst" ] || [ -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink "$dst")"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?"
        user "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -rn 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

install_dotfiles () {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.sym' -not -path '*.git*')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}

setup_gitconfig
install_dotfiles

# if we're on a mac, let's install and setup homebrew
if [ "$(uname -s)" == "Darwin" ]
then
  user "Do you want to install brew & OSX dependencies, your password may be requested? (y/n)"
  read -rn 1 response

  if [ "$response" == 'y' ]; then
    info 'installing dependencies'
    if source macos/osx-init > /tmp/osx-install.log 2>&1
    then
        success 'dependencies installed'
    else
        fail 'error installing dependencies'
    fi
  else
    info 'not installing dependencies'
  fi
fi

echo ''
echo ' all installed!'
