FROM alpine
MAINTAINER jonathan@wilkins.tech

RUN apk update && apk add shadow perl zsh vim curl git tmux ctags go libc-dev make

RUN go get -u -v \
    github.com/mitchellh/go-homedir \
    github.com/sirupsen/logrus \
    github.com/tcnksm/go-input \
    github.com/genuinetools/pkg/cli

RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh 

RUN chsh -s /bin/zsh

WORKDIR /dotfiles

