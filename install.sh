#!/bin/bash -e
# shellcheck disable=SC2044
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
    echo "removing /etc/sudoers.d/$USER"
    sudo rm -f /etc/sudoers.d/"$USER"
    echo "adding /etc/sudoers.d/$USER"
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/"$USER" >/dev/null
}

install_base() {
    # TODO(jwilkins): Make this arch agnostic
    sudo apt update -qq || true
    sudo apt -yqq upgrade
    < packages xargs sudo apt install -yqq --no-install-recommends

    if [[ ! "$IS_SERVER" ]]; then
        sudo apt -yqq install signal-desktop compton
    fi

    sudo apt -y autoremove
    sudo apt autoclean
    sudo apt clean

    # install polybar
    if [[ ! -f /usr/local/bin/polybar ]] && [[ ! "$IS_SERVER" ]]; then
        tmpdir=$(mktemp -d)
        (
            cd "$tmpdir" || exit 1;
            git clone https://github.com/jaagr/polybar.git;
            cd polybar;
            ./build.sh
        ) || fail "couldn't cd to $tmpdir to install polybar"
    fi

    # install fonts
    if [[ ! "$IS_SERVER" ]]; then
        install_fonts
    fi
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
	sudo bash -c 'cat <<-EOF > /etc/apt/sources.list.d/signal.list
deb https://deb.nodesource.com/node_11.x stretch main
	EOF'
	sudo bash -c 'cat <<-EOF > /etc/apt/sources.list.d/spotify.list
deb http://repository.spotify.com stable non-free
	EOF'

    # keys
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    curl -s https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410

    # ppa
    sudo add-apt-repository -y ppa:hluk/copyq

    # speed up apt
    sudo mkdir -p /etc/apt/apt.conf.d
    sudo rm -f /etc/apt/apt.conf.d/99translations
	echo 'Acquire::Languages "none";' | sudo tee -a /etc/apt/apt.conf.d/99translations >/dev/null
}

install_fonts() {
	mkdir -p "$HOME/.fonts"
    if fc-list | grep 'mononoki'; then
        info "mononoki font exists"
    else
        tmpdir=$(mktemp -d)
        info "installing Mononoki font"
        (
            cd "$tmpdir" || exit 1;
            url="$(curl -fsSL https://api.github.com/repos/madmalik/mononoki/releases | jq '.[0].assets[0].browser_download_url')";
            url=$(echo "$url" | tr -d '"');
            curl -fsSL "$url" -o mononoki.zip;
            if [[ ! -f mononoki.zip ]]; then
                exit 1
            fi
            unzip "mononoki.zip";
            rm "mononoki.zip";
            mv ./* "$HOME/.fonts";
            fc-cache -fv
        ) || fail "couldn't download Mononoki"
    fi

    if fc-list | grep 'iosevka'; then
        info "iosevka font exists"
    else
        tmpdir=$(mktemp -d)
        info "installing Iosevka font"
        (
            cd "$tmpdir";
            url="$(curl -fsSL https://api.github.com/repos/be5invis/Iosevka/releases | jq '.[0].assets[0].browser_download_url')";
            url=$(echo "$url" | tr -d '"');
            curl -fsSL "$url" -o iosevka.zip;
            if [[ ! -f iosevka.zip ]]; then
                exit 1
            fi
            unzip "iosevka.zip";
            rm "iosevka.zip";
            mv ./ttf/* "$HOME/.fonts";
            fc-cache -fv
        ) || fail "couldn't download Iosevka"
    fi
}

setup_zsh() {
    # oh-my-zsh
    if ! [ -s "$HOME/.oh-my-zsh" ]; then
        git clone git://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
    fi
    success "oh-my-zsh installed"

    THEME_DIR="$HOME/.oh-my-zsh/custom/themes"
    if [[ ! -d $THEME_DIR ]]; then
        mkdir -p "$THEME_DIR"
    fi
    info "linking theme"
    ln -sf "$HOME/.zsh-prompt" "$THEME_DIR/wilkins-custom.zsh-theme"
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
    cargo install shellharden ripgrep lsd bat miniserve ffsend hunter cargo-update || true
    if [[ ! "$IS_SERVER" ]]; then
        cargo install --git https://github.com/jwilm/alacritty || true
    fi
    info "updating rust packages"
    cargo install-update -a
}

install_go() {
    GO_VERSION=$(curl -fsSL "https://golang.org/VERSION?m=text")
    INSTALLED_VERSION="none"
    if [ -s /usr/local/go/bin/go ]; then
        INSTALLED_VERSION="$(go version | cut -d' ' -f3)"
    fi
    GO_SRC=/usr/local/go
    sudo mkdir -p "$GO_SRC"
    mkdir -p "$HOME/go"
    if [[ "$INSTALLED_VERSION" != "$GO_VERSION" ]]; then
        GO_VERSION=${GO_VERSION#go}
        info "installing new go version: $GO_VERSION"
		sudo rm -rf "$GO_SRC"

        local_arch=$ARCH
        if [[ "$local_arch" == "arm" ]]; then
            local_arch="armv6l"
        fi
        url="https://storage.googleapis.com/golang/go$GO_VERSION.$KERNEL-$local_arch.tar.gz"
        info "downloading from url $url"
        curl -fsSL "$url" | sudo tar -v -C /usr/local -xz

        info "updating go packages"
        GOPATH="$HOME/go" go get -u all
    fi

    success "go installed, running post-install actions"
    go get -u honnef.co/go/tools/cmd/staticcheck \
        github.com/prasmussen/gdrive \
        github.com/motemen/ghq \
        github.com/evalexpr/makedl \
        github.com/davecheney/httpstat
}

install_python3() {
    info "installing python3"
    sudo apt install -yqq python3 \
        python3-pip \
        python3-setuptools \
        python3-dev \
        --no-install-recommends
    if ! command -v pip3 >/dev/null 2>&1 || ! [ -s "$HOME"/.local/bin/pip3 ]; then
        tmpdir=$(mktemp -d)
        curl -fsSL "https://bootstrap.pypa.io/get-pip.py" -o "/$tmpdir/get-pip.py"
        python3 "/$tmpdir/get-pip.py" --user
    fi
    success "python3 and pip installed, running post-install actions"
    "$HOME"/.local/bin/pip3 install --user --upgrade pip
    "$HOME"/.local/bin/pip3 install --quiet --user --upgrade \
        yapf \
        pipenv \
        icdiff \
        pipreqs \
        magic-wormhole \
        httpie \
        docker-compose \
        grip
}

install_extras() {
    install_rust
    install_go
    install_python3

    # fzf
    if ! [ -s "$HOME/.fzf" ]; then
        info "installing fzf"
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && \
            "$HOME/.fzf/install"
    else
        info "updating fzf"
        (
            cd "$HOME"/.fzf;
            git pull;
            ./install
        )
    fi
    success "fzf installed"

    # yarn
    info "installing yarn"
    curl -fsSL "https://dl.yarnpkg.com/debian/pubkey.gpg" | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update -qq && sudo apt install -yqq yarn --no-install-recommends
    success "yarn installed"

    # yarn post-install
    yarn global add diff-so-fancy 2>/dev/null

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

        user_input "what is your GitHub author name? (Default: evalexpr)" author
        author=${author:-evalexpr}

        user_input "what is your GitHub email? (Default: wilkinsphysics@gmail.com)" email
        email=${email:-wilkinsphysics@gmail.com}

        user_input "do you want to use a GPG key with git? [y/N]" using_gpg
        using_gpg=${using_gpg:-N}

        key=
        if [ "$using_gpg" != "${using_gpg#[Yy]}" ] ;then
            gpg --list-keys --keyid-format LONG
            user_input "which key" key
        fi

        cp git/gitconfig "$HOME/.gitconfig"

        sed -e "s/AUTHOR_NAME/$author/g" -e "s/AUTHOR_EMAIL/$email/g" -e "s/GIT_CREDENTIAL_HELPER/$store/g" -i "$HOME/.gitconfig"
        if ! [ -z "$key" ]; then
            sed -e "s/AUTHOR_GPG_KEY/$key/g" -e "s/gpgsign = false/gpgsign = true/g" -i "$HOME/.gitconfig"
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
            info "linking $file to $dest"
            sudo ln -s "$(readlink -f "$file")" "$dest"
        fi
    done
}

setup_vim() {
    # install latest vim
    if [[ ! -f /usr/local/bin/vim ]]; then
        tmpdir=$(mktemp -d)
        (
            cd "$tmpdir" || exit 1;
            git clone https://github.com/vim/vim.git;
            cd vim/src || exit 1;
            tag=$(git describe --tags)
            info "checking out tag $tag"
            git checkout "$tag" || fail "couldn't check out $tag";
            ./configure --with-features=huge \
                --enable-multibyte \
                --enable-rubyinterp=yes \
                --enable-pythoninterp=yes \
                --with-python-config-dir=/usr/lib/python2.7/config \
                --enable-python3interp=yes \
                --with-python3-config-dir=/usr/lib/python3.5/config \
                --enable-perlinterp=yes \
                --enable-luainterp=yes \
                --enable-gui=gtk2 \
                --enable-cscope \
                --prefix=/usr/local;
            make -j VIMRUNTIMEDIR=/usr/local/share/vim/vim81;
            sudo make install
        ) || fail "couldn't install vim"
    fi

    # install submodules
    info "updating submodules"
    git submodule update --remote --merge --progress
    
    user_input "do you want to set up YouCompleteMe [y/N]" setup_ycm
    setup_ycm=${setup_ycm:-N}
    ycm_dir="vim.sym/pack/bundle/start/YouCompleteMe"
    if [[ -d "$ycm_dir" && "$setup_ycm" == "y" || "$setup_ycm" == "Y" ]]; then
        (
            cd "$ycm_dir" || exit 1;
            info "setting up YouCompleteMe"
            git submodule update --init --recursive;
            python3 install.py --go-completer --ts-completer --rust-completer;
        )
    fi

    vim -u NONE -c "helptags ALL" -c GoInstallBinaries -c q >/dev/null 2>&1
}

pre_install() {
    sudo apt install -yqq --no-install-recommends curl apt-transport-https
}

post_install() {
    # check ssh key for host
    key_path="$HOME/.ssh/$(hostname)"
    info "ensuring ssh key at $key_path exists"
    if [[ ! -f "$key_path.pub" ]]; then
        info "ssh key does not exist, creating"
        ssh-keygen -t rsa -b 4096 -f "$key_path"
    fi

    mkdir -p "$HOME"/{workspace/checkouts,tmp,downloads,documents}
    mkdir -p "$HOME"/media/{pictures/wallpapers,screenshots,videos,music}
    mkdir -p "$HOME"/go/src/github.com/evalexpr/
    ln -sf "$HOME"/go/src/github.com/evalexpr/ "$HOME"/workspace/go

    if [[ ! "$IS_SERVER" ]]; then
        sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(command -v alacritty)" 100 || true
        sudo update-alternatives --set x-terminal-emulator "$(command -v alacritty)"
    fi

	sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 100
	sudo update-alternatives --set vi /usr/local/bin/vim

	sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 100
	sudo update-alternatives --set editor /usr/local/bin/vim

    # change shell to zsh
    if [[ "$SHELL" != *"zsh"* ]]; then
        info "changing shell to zsh"
        chsh -s "$(command -v zsh)"
    fi

    # temporary removal of go.mod, go.sum
    rm -f go.mod go.sum
}

main() {
    local cmd="$1"
    readonly KERNEL="$(uname -s | tr '[:upper:]' '[:lower:]')"
    readonly ARCH="$(determine_arch)"
    readonly DIST="$(lsb_release -si | tr '[:upper:]' '[:lower:]')"
    info "running for kernel: $KERNEL and arch $ARCH"

    info "running pre-install"
    pre_install

    if [[ ! -z $cmd && $cmd == "init" ]]; then
        info "setting up sudo"
        setup_sudo

        info "installing sources"
        install_sources

        info "installing base"
        install_base

        info "installing extras"
        install_extras
    fi

    info "setting up git"
    setup_git

    info "linking dotfiles"
    setup_dotfiles

    info "installing oh-my-zsh"
    setup_zsh

    info "setting up systemd"
    setup_systemd

    info "setting up vim"
    setup_vim

    info "running post-install"
    post_install

    success "installation complete"
}

main "$@"
