#!/bin/bash -e
# shellcheck disable=SC2044
set -o pipefail
DOTFILES_ROOT=$(pwd -P)
PATH="$PATH:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin"

info() {
    printf "[\\033[00;34m.\\033[0m] %s\\n" "$1"
}

success() {
    printf "\\033[2K[\\033[00;32m✔\\033[0m] %s\\n" "$1"
}

warn() {
    printf "\\033[2K[\\033[00;33m!\\033[0m] %s\\n" "$1"
}

fail() {
    printf "\\033[2K[\\033[0;31m✘\\033[0m] %s\\n" "$1"
    exit 1
}

finish() {
    success "$1"
    exit 0
}

user_input() {
    read -re -p $'\033[0;33m'"$1"$'\033[0m: ' "$2"
}

link_file() {
    local src="$1" dest="$2"
    local overwrite="" backup="" skip="" action=""

    # check if the destinaton is already a file/dir/symlink
    if [ -f "$dest" ] || [ -d "$dest" ] || [ -L "$dest" ]; then
        if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
            # shellcheck disable=SC2155
            local current="$(readlink "$dest")"

            if [ "$current" == "$src" ]; then
                skip=true
            else
                info "file already exists: $dest ($(basename "$src")), what do you want to do?"
                user_input "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?" action

                case "$action" in
                o)
                    overwrite=true
                    ;;
                O)
                    overwrite_all=true
                    ;;
                b)
                    backup=true
                    ;;
                B)
                    backup_all=true
                    ;;
                s)
                    skip=true
                    ;;
                S)
                    skip_all=true
                    ;;
                *) ;;

                esac
            fi
        fi

        overwrite=${overwrite:-$overwrite_all}
        backup=${backup:-$backup_all}
        skip=${skip:-$skip_all}

        if [ "$overwrite" == "true" ]; then
            rm -rf "$dest" || fail "could not remove $dest"
            success "removed $dest"
        fi

        if [ "$backup" == "true" ]; then
            mv "$dest" "$dest.backup" || fail "could not move $dest to $dest.backup"
            success "moved $dest to $dest.backup"
        fi

        if [ "$skip" == "true" ]; then
            info "skipped $src"
        fi
    fi

    if [ "$skip" != "true" ]; then
        ln -s "$1" "$2" || fail "could not link $1 to $2"
        success "linked $1 to $2"
    fi
}

setup_sudo() {
    info "setting up sudo"
    sudo gpasswd -a "$USER" sudo || true
    sudo gpasswd -a "$USER" systemd-journal || true
    sudo gpasswd -a "$USER" systemd-network || true
    sudo gpasswd -a "$USER" docker || true

    sudo mkdir -p /etc/sudoers.d/
    if ! sudo grep -qr "$USER" /etc/sudoers{,.d}/; then
        echo "adding /etc/sudoers.d/$USER"
        echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/"$USER" >/dev/null
    fi
}

install_programs() {
    info "installing programs via brew"
    brew bundle --file=./Brewfile
}

shell_setup() {
    info "setting up shell"

    # prezto
    PREZTO_DIR="$HOME/.zprezto"
    if ! [ -d "$PREZTO_DIR" ]; then
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "$PREZTO_DIR"
    else
        info "updating prezto"
        (
            cd "$PREZTO_DIR"
            git pull
            git submodule update --init --recursive
        )
    fi
    success "prezto installed"

    # install dircolors
    info "linking dircolors"
    ln -sf "$PWD/nord-dircolors/src/dir_colors" "$HOME/.dir_colors"
    success "linked dircolors"
}

setup_git() {
    info "setting up git"

    if ! [ -s "$HOME/.gitconfig" ]; then
        my_sed="sed"
        store="cache"

        if [[ "$OSTYPE" == "darwin"* ]]; then
            my_sed="gsed"
            store="osxkeychain"
        fi

        user_input "what is your GitHub author name? (Default: evalexpr)" author
        author=${author:-evalexpr}

        user_input "what is your GitHub email? (Default: jonathan@wilkins.tech)" email
        email=${email:-jonathan@wilkins.tech}

        user_input "do you want to use a GPG key with git? [y/N]" using_gpg
        using_gpg=${using_gpg:-N}

        key=
        if [ "$using_gpg" != "${using_gpg#[Yy]}" ]; then
            gpg --list-keys --keyid-format LONG
            user_input "which key" key
        fi

        cp git/gitconfig "$HOME/.gitconfig"

        $my_sed -e "s/AUTHOR_NAME/$author/g" -e "s/AUTHOR_EMAIL/$email/g" -e "s/GIT_CREDENTIAL_HELPER/$store/g" -i "$HOME/.gitconfig"
        if [ -n "$key" ]; then
            $my_sed -e "s/AUTHOR_GPG_KEY/$key/g" -e "s/gpgsign = false/gpgsign = true/g" -i "$HOME/.gitconfig"
        fi
        success "created gitconfig"
    else
        info "skipped gitconfig"
    fi
}

setup_dotfiles() {
    info "linking dotfiles"

    local overwrite_all=false backup_all=false skip_all=false
    for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.sym' -not -path '*.git*'); do
        dest="$HOME/.$(basename "${src%.*}")"
        link_file "$src" "$dest"
    done
}

setup_systemd() {
    info "setting up systemd"
    for file in $(find -H config.sym/systemd/system -type f -name '*.service'); do
        dest="/etc/systemd/system/$(basename "$file")"
        if ! [ -L "$dest" ]; then
            info "linking $file to $dest"
            sudo ln -s "$(readlink -f "$file")" "$dest"
        fi
    done
}

vim_post_install() {
    info "init submodules"
    git submodule init
    info "updating submodules"
    git submodule update --remote --merge --progress
    info "finished installing submodules"

    info "running vim commands"
    vim -c ":GoInstallBinaries" -c q
    vim -c "helptags ALL" -c q
    vim -c ":call coc#util#install()" -c q
}

linux_pre_install() {
    # TODO(evalexpr): make this arch agnostic
    info "installing linux pre-requisites"

    # speed up apt
    sudo mkdir -p /etc/apt/apt.conf.d
    sudo rm -f /etc/apt/apt.conf.d/99translations
    echo 'Acquire::Languages "none";' | sudo tee -a /etc/apt/apt.conf.d/99translations >/dev/null

    sudo apt update -qq || true
    sudo apt -yqq upgrade || true
    sudo apt -y autoremove || true
    sudo apt autoclean || true
    sudo apt clean || true

    sudo apt install -yqq --no-install-recommends curl apt-transport-https || true

    # install linuxbrew
    if ! type brew &> /dev/null; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    fi
}

setup_home() {
    mkdir -p "$HOME"/.ssh
    mkdir -p "$HOME"/{workspace/checkouts,tmp}
    mkdir -p "$HOME"/go/src/github.com/evalexpr
}

ensure_vscode_extension() {
    code --list-extensions | xargs | grep -q "$1" || code --install-extension "$1" --force
}

setup_vscode() {
    [ ! "$(command -v code 2>/dev/null)" ] && \
        warn "vscode not installed, ignoring extensions" && return

    info "setting up vscode"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        SETTINGS_LOCATION="$HOME/Library/Application Support/Code/User/settings.json"
    else
        SETTINGS_LOCATION="$HOME/.config/Code/User/settings.json"
    fi

    rm -f "$SETTINGS_LOCATION"
    ln -sf "$PWD/vscode/settings.json" "$SETTINGS_LOCATION"

    info "installing vscode extensions"
    # Vim
    ensure_vscode_extension vscodevim.vim
    # TODO Highlight
    ensure_vscode_extension wayou.vscode-todo-highlight
    # Tailwind CSS IntelliSense
    ensure_vscode_extension bradlc.vscode-tailwindcss
    # Gruvbox Theme
    ensure_vscode_extension jdinhlife.gruvbox
    # GitLens
    ensure_vscode_extension eamodio.gitlens
    # DotENV
    ensure_vscode_extension mikestead.dotenv
    # Docker
    ensure_vscode_extension ms-azuretools.vscode-docker
    # CSS Peek
    ensure_vscode_extension pranaygp.vscode-css-peek
    # Color Highlight
    ensure_vscode_extension naumovs.color-highlight
    # Material Icon Theme
    ensure_vscode_extension PKief.material-icon-theme
    # Go
    ensure_vscode_extension ms-vscode.Go
    # Nord theme
    ensure_vscode_extension arcticicestudio.nord-visual-studio-code

    success "finished installing vscode"
}

post_install() {
    info "running post install commands"

    vim_post_install
    setup_home

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100 || true
        sudo update-alternatives --set editor /usr/bin/vim || true
    fi

    # change shell to zsh
    if [[ "$SHELL" != *"zsh"* ]]; then
        info "changing shell to zsh"
        sudo sh -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells'
        chsh -s "$(command -v zsh)"
    fi

    # enable fzf for zsh
    "$(brew --prefix)"/opt/fzf/install
}

install_dots() {
    info "installing dotfiles"
    setup_git
    setup_dotfiles
    shell_setup
    setup_vscode
    post_install
}

main() {
    local cmd="$1"
    readonly KERNEL="$(uname -s | tr '[:upper:]' '[:lower:]')"
    info "running for kernel: $KERNEL"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # If we don't pass a command, we just want to install dotfiles
        if [[ -z $cmd ]]; then
            install_dots || fail "could not install dotfiles"
            finish "installation complete"
        fi

        if [[ $cmd == "git" ]]; then
            setup_git
            finish "git installation complete"
        fi

        if [[ $cmd == "init" ]]; then
            info "running pre-install"
            ./macos/install.sh

            setup_sudo
            install_programs
            install_dots
        fi
    fi

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        info "running pre-install"
        linux_pre_install

        # If we don't pass a command, we just want to install dotfiles
        if [[ -z $cmd ]]; then
            install_dots || fail "could not install dotfiles"
            setup_systemd
            finish "installation complete"
        fi

        if [[ $cmd == "init" ]]; then
            setup_sudo
            install_programs
            install_dots
        fi
    fi

    finish "installation complete"
}

main "$@"
