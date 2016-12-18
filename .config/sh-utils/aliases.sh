# --- generally useful ---
alias ..='cd ..'
alias l='ls -lFh'
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
alias tarup='tar -zcf'
alias tardown='tar -zxf'
alias update='sudo apt-update; sudo apt upgrade -y'
alias shutdown='sudo shutdown now'
alias restart='sudo shutdown -r now'
alias listcron='sudo /home/$USER/bin/listcron'
alias listservicespi='service --status-all | grep +'
alias listservices='sudo systemctl -r --type service --all | grep " active"'
alias mpack='makepkg -s'
alias ipack='makepkg -i'
alias cupdate='find .-name PKGBUILD -execdir makepkg -si \;'
alias aursearch='cower -s $1'
alias aurdl='cd /home/$USER/tmp; cower -d $1'

# --- dotfile shortcuts ---
alias zshrc='vi ~/.zshrc'
alias i3config='vi ~/.i3/config'
alias terminalrc='vi /home/$USER/.config/xfce4/terminal/terminalrc'
alias htoprc='vi /home/$USER/.config/htop/htoprc'
alias vimrc='vi ~/.vimrc'
alias sshconfig='vim ~/.ssh/config'
alias vimupdate='vim +PluginInstall +qall'

# --- git ---
alias gs='git status'
alias ga='git add --all'
alias gap='git add --patch'
alias gpull='git pull'
alias gitshove='gpull; ga; git commit -m $1'

# --- tmux ---
alias tc='tmux new -s $1'
alias ta='tmux attach -t $1'
alias tl='tmux list-sessions'

# --- docker ---
alias dstop='docker stop $(docker ps -a -q)'
alias drma='docker rmi $(docker ps -a -q)'
alias debian='docker run -it debian bash'

# --- misc ---
alias torrent='deluged; deluge-web&;'
alias stoptorrent='pkill deluge; pkill deluged; pkill deluge-web;'
alias airvpn='sudo openvpn --config --mute-replay-warnings /home/$USER/vpn/AirVPN_United-Kingdom_UDP-443.ovpn'
alias scp='scp -P 999'
alias checkip='curl icanhazip.con'
alias src='source ~/.zshrc'
alias pls='sudo $(fc -ln -1)'
alias irc='weechat'

# --- python ---
alias vv='virtualenv venv'
alias svenv='source ./venv/bin/activate'

# --- arch specific ---
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDF_VTNR" -eq 1 ]; then
    exec startx
fi
