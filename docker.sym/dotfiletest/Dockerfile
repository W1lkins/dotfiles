FROM alpine

RUN apk update && apk add shadow perl zsh vim curl git tmux ctags

RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh 

RUN chsh -s /bin/zsh

WORKDIR /project

