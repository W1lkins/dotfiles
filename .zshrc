# === exports, plugins & themes ===
export ZSH=/home/jonathan/.oh-my-zsh
ZSH_THEME=afowler
plugins=(git nvm history jump extract gitignore)
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export VISUAL=vim
export EDITOR=vim
source $ZSH/oh-my-zsh.sh
export TERM=xterm-256color
export CLICOLOR=1
export SPOTIPY_CLIENT_ID='ea8316fa93a740ad99f6e773bfedb2da'
export SPOTIPY_CLIENT_SECRET='8e5f7a3790144c7e90e376ae670554b1'
export SPOTIPY_REDIRECT_URI='http://localhost/listentothis/callback/'
#setxkbmap -v gb
#setxkbmap -option caps:swapescape # swap capslock with escape
export GOPATH=~/dev/go
export PATH=$PATH:$GOPATH/bin

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-eighties.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# === general aliases ===
alias ..='cd ..'
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias c='clear'
alias l='ls -lh'
alias la='ls -lAFh'
alias lr='ls -tRFh'
alias lt='ls -ltFh'
alias ll='ls -l'
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'
alias grep='grep --color=auto'
alias vi='vim'

# === system commands ===
alias update='sudo pacman -Syu'
alias shutdown='sudo shutdown now'
alias restart='sudo restart now'

# === dotfile shortcuts ===
alias zshrc='vim ~/.zshrc'
alias vimrc='vim ~/.vimrc'
alias sshconfig='vim ~/.ssh/config'
alias terminalrc='vim /home/jonathan/.config/xfce4/terminal/terminalrc'
alias i3config='vim ~/.i3/config'
alias vimupdate='vim +PluginInstall +qall'

# === git shortcuts ===
alias gs='git status'
alias ga='git add .'
alias gap='git add --patch'
alias gpull='git pull'
alias gitshove='git pull; git add .; git commit -m $1'

# === tmux commands ===
alias tc='tmux new -s $1'
alias ta='tmux attach -t $1'
alias tl='tmux list-sessions'

# === useful stuff ===
alias scpi='scp -P 999 $1 pi@pi-two:/home/pi/'
alias picam='scp -r -P 999 pi@pi-two:/home/pi/mmal/m-video /home/jonathan/media/video/pi_cam_videos'
alias checkip='curl icanhazip.com'
alias samba='cd /mnt/samba'
alias pi='ssh home-pi'
alias src='source ~/.zshrc'
alias pls='sudo $(fc -ln -1)'
alias dockerenv='eval $(docker-machine env default)' # fix docker
alias debian='docker run -it debian bash'
#eval $(docker-machine env default)
alias vv='virtualenv venv' # python venv creation
alias tarup='tar -zcf'
alias tardown='tar -zxf'
alias irc='weechat'
alias listservices='sudo systemctl -r --type service --all | grep " active"'
alias grun='go run *.go'
alias hearthstone='wine "c:\Program Files (x86)\Battle.net\Battle.net.exe"'

# === functions ===
makenote() {
    if [ $# -eq 0 ]
    then
        local directory=/home/$USER/doc/notes/
        local filename=note_`date +%H%M%S`
        touch $directory$filename
        vi $directory$filename
    else
        local directory=/home/$USER/doc/notes/
        touch $directory$1
        vi $directory$1
    fi
}

utop() {
    if [ $# -eq 0 ]
    then
        htop -u jonathan
    else
        htop -u $1
    fi
}

# === arch stuff ===
alias mpack='makepkg -s'
alias ipack='makepkg -i'
alias cupdate='find .-name PKGBUILD -execdir makepkg -si \;'
# startx at login
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
      exec startx
fi

