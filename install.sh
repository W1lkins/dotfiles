#!/bin/bash -e
set -o pipefail

DOTFILES_ROOT=$(pwd -P)
export PATH="$PATH:/usr/local/go/bin:$HOME/.cargo/bin:$HOME"/.local/bin

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
    exit
}

user_input() {
    read -re -p $'\033[0;33m'"$1"$'\033[0m: ' "$2"
}

determine_arch() {
    arch=$(arch)
    case $arch in
        x86*) arch=amd64;;
        arm*) arch=arm;;
    esac
    echo "$arch"
}

link_file() {
    local src="$1" dest="$2"
    local overwrite="" backup="" skip="" action=""

    # check if the destinaton is already a file/dir/symlink
    if [ -f "$dest" ] || [ -d "$dest" ] || [ -L "$dest" ]; then
        if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ];then
            # shellcheck disable=SC2155
            local current="$(readlink "$dest")"

            if [ "$current" == "$src" ]; then
                skip=true;
            else
                info "file already exists: $dest ($(basename "$src")), what do you want to do?"
                user_input "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?" action

                case "$action" in
                    o)
                        overwrite=true;;
                    O)
                        overwrite_all=true;;
                    b)
                        backup=true;;
                    B)
                        backup_all=true;;
                    s)
                        skip=true;;
                    S)
                        skip_all=true;;
                    *)
                        ;;
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
    sudo groupadd sudo || true
    sudo groupadd docker || true
    sudo groupadd systemd-journal || true
    sudo groupadd systemd-network || true

    sudo gpasswd -a "$USER" sudo
    sudo gpasswd -a "$USER" systemd-journal
	sudo gpasswd -a "$USER" systemd-network
	sudo gpasswd -a "$USER" docker

    sudo mkdir -p /etc/sudoers.d/
    echo "Removing /etc/sudoers.d/$USER"
    sudo rm -f /etc/sudoers.d/"$USER"
    echo "Adding /etc/sudoers.d/$USER"
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/"$USER" >/dev/null
}

install_base() {
    # TODO(jwilkins): Make this arch agnostic
    sudo apt update -qq || true
    sudo apt -yqq upgrade
    < packages xargs sudo apt install -yqq --no-install-recommends

    sudo apt autoremove
    sudo apt autoclean
    sudo apt clean
}

install_sources() {
	# set up sources
	sudo bash -c 'cat <<-EOF > /etc/apt/sources.list.d/google-cloud-sdk.list
    deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main
	EOF'
	sudo bash -c 'cat <<-EOF > /etc/apt/sources.list.d/google-chrome.list
	deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
	EOF'
	sudo bash -c 'cat <<-EOF > /etc/apt/sources.list.d/signal.list
    deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main
	EOF'

    # keys
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    curl -s https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -

    # speed up apt
    sudo mkdir -p /etc/apt/apt.conf.d
    sudo rm -f /etc/apt/apt.conf.d/99translations
	echo 'Acquire::Languages "none";' | sudo tee -a /etc/apt/apt.conf.d/99translations >/dev/null
}

install_oh_my_zsh() {
    # oh-my-zsh
    if ! [ -s "$HOME/.oh-my-zsh" ]; then
        git clone git://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
    fi
    success "oh-my-zsh installed"
}

install_rust() {
    if ! [ -s "$HOME"/.cargo/bin/rustc ]; then
        curl -fsSL "https://sh.rustup.rs" | bash
    fi
    success "rust installed, running post-install actions"

    # use nightly rust
    rustup install nightly
    rustup default nightly
    rustup update
    cargo install shellharden ripgrep exa bat miniserve || true
}

install_go() {
    GO_VERSION=$(curl -fsSL "https://golang.org/VERSION?m=text")
    INSTALLED_VERSION="none"
    if [ -s /usr/local/go/bin/go ]; then
        INSTALLED_VERSION="$(go version | cut -d' ' -f3)"
    fi
    GO_SRC=/usr/local/go
    sudo mkdir -p "$GO_SRC"
    if [[ "$INSTALLED_VERSION" != "$GO_VERSION" ]]; then
        GO_VERSION=${GO_VERSION#go}
        info "installing new go version: $GO_VERSION"
		sudo rm -rf "$GO_SRC"
        curl -fsSL "https://storage.googleapis.com/golang/go$GO_VERSION.$KERNEL-$ARCH.tar.gz" | sudo tar -v -C /usr/local -xz
    fi
    success "go installed, running post-install actions"

    # go post-install
    # vim-go
    go get github.com/alecthomas/gometalinter \
        github.com/davidrjenni/reftools/cmd/fillstruct \
        github.com/fatih/gomodifytags \
        github.com/fatih/motion \
        github.com/josharian/impl \
        github.com/jstemmer/gotags \
        github.com/kisielk/errcheck \
        github.com/klauspost/asmfmt/cmd/asmfmt \
        github.com/koron/iferr \
        github.com/mdempsky/gocode \
        github.com/rogpeppe/godef \
        github.com/stamblerre/gocode \
        github.com/zmb3/gogetdoc \
        golang.org/x/lint/golint \
        golang.org/x/tools/cmd/goimports \
        golang.org/x/tools/cmd/gorename \
        golang.org/x/tools/cmd/guru \
        honnef.co/go/tools/cmd/keyify

    # others
    go get honnef.co/go/tools/cmd/staticcheck
    go get github.com/prasmussen/gdrive
    go get github.com/motemen/ghq
}

install_python3() {
    info "installing python3"
    sudo apt install -yqq python3 \
        python3-pip \
        python3-setuptools \
        python3-dev \
        python3-distutils \
        --no-install-recommends
    if ! command -v pip3 >/dev/null 2>&1 || ! [ -s "$HOME"/.local/bin/pip3 ]; then
        curl -fsSL "https://bootstrap.pypa.io/get-pip.py" -o /tmp/get-pip.py
        python3 /tmp/get-pip.py --user
    fi
    success "python3 and pip installed, running post-install actions"
    "$HOME"/.local/bin/pip3 install --quiet --user --upgrade \
        yapf \
        pipenv \
        icdiff \
        pipreqs \
        magic-wormhole \
        docker-compose
}

install_extras() {
    install_oh_my_zsh
    install_rust
    install_go
    install_python3

    # fzf
    if ! [ -s "$HOME/.fzf" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && \
            "$HOME/.fzf/install"
    fi
    success "fzf installed"

    # yarn
    info "installing yarn"
    curl -fsSL "https://dl.yarnpkg.com/debian/pubkey.gpg" | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update -qq && sudo apt install -yqq yarn --no-install-recommends
    success "yarn installed"

    # docker
    if ! command -v docker >/dev/null 2>&1; then
        curl -fsSL "https://get.docker.com" | bash
    fi
    success "docker installed"

    # 1password cli
    if ! [ -s /usr/local/bin/op ]; then
        OP=op_"$KERNEL"_"$ARCH"_v0.5.5.zip
        curl -sSLOf "https://cache.agilebits.com/dist/1P/op/pkg/v0.5.5/$OP"
        unzip "$OP"
        sudo mv op /usr/local/bin/op
        rm op.sig "$OP"
    fi
    success "1password cli installed"

    # speedtest
    curl -sSL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | sudo tee /usr/local/bin/speedtest >/dev/null
	sudo chmod +x /usr/local/bin/speedtest
}

setup_git() {
    if ! [ -s "$HOME/.gitconfig" ]; then
        store="cache"
        if [[ "$OSTYPE" == "Darwin"* ]]; then
            store="osxkeychain"
        fi

        user_input "What is your GitHub author name? (Default: W1lkins)" author
        author=${author:-W1lkins}

        user_input "What is your GitHub email? (Default: wilkinsphysics@gmail.com)" email
        email=${email:-wilkinsphysics@gmail.com}

        user_input "Do you want to use a GPG key with git? [y/N]" using_gpg
        using_gpg=${using_gpg:-N}

        key=
        if [ "$using_gpg" != "${using_gpg#[Yy]}" ] ;then
            gpg --list-secret-keys --keyid-format LONG
            user_input "Which key" key
        fi

        cp git/gitconfig "$HOME/.gitconfig"

        sed -e "s/AUTHOR_NAME/$author/g" -e "s/AUTHOR_EMAIL/$email/g" -e "s/GIT_CREDENTIAL_HELPER/$store/g" -i "$HOME/.gitconfig"
        echo "got past name etc."
        if ! [ -z "$key" ]; then
            sed -e "s/AUTHOR_GPG_KEY/$key/g" -e "s/gpgsign = false/gpgsign = true/g" -i "$HOME/.gitconfig"
            echo "after gpg key"
        fi
        if command -v ghq >/dev/null 2>&1; then
            # Use "|" as a delimiter since $HOME/workspace contains "/"
            sed -e "s|GHQ_ROOT|$HOME/workspace|g" -i "$HOME/.gitconfig"
        fi

        success "created gitconfig"
    else
        info "skipped gitconfig"
    fi
}


setup_dotfiles() {
    local overwrite_all=false backup_all=false skip_all=false

    # shellcheck disable=SC2044
    for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.sym' -not -path '*.git*')
    do
        dest="$HOME/.$(basename "${src%.*}")"
        link_file "$src" "$dest"
    done
}

setup_systemd() {
    for file in $(find -H config.sym/systemd/system -type f -name '*.service')
    do
        dest="/etc/systemd/system/$(basename "$file")"
        if ! [ -L "$dest" ]; then
            info "Linking $file to $dest"
            sudo ln -s "$(readlink -f "$file")" "$dest"
        fi
    done
}

setup_vim() {
    (
        cd "$HOME"/.vim || exit 1;
        nvim +PlugClean +PlugUpdate +UpdateRemotePlugins +qa
    ) || fail "couldn't cd to $HOME/.vim"
}

post_install() {
    mkdir -p "$HOME"/{workspace,tmp,downloads,documents}
    mkdir -p "$HOME"/media/{pictures/wallpapers,screenshots,videos,music}
}

main() {
    local cmd="$1"
    readonly KERNEL="$(uname -s | tr '[:upper:]' '[:lower:]')"
    readonly ARCH="$(determine_arch)"
    readonly DIST="$(lsb_release -si | tr '[:upper:]' '[:lower:]')"
    info "Running for kernel: $KERNEL and arch $ARCH"

    if [[ ! -z $cmd && $cmd == "init" ]]; then
        info "setting up sudo"
        setup_sudo

        info "installing sources"
        install_sources

        info "installing base"
        install_base

        info "installing extras"
        install_extras

        info "running post-install actions"
        post_install
    fi

    info "setting up git"
    setup_git

    info "linking dotfiles"
    setup_dotfiles

    info "setting up systemd"
    setup_systemd

    info "setting up vim"
    setup_vim

    success "installation complete"
}

main "$@"
