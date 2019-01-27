FROM debian:buster-slim

LABEL maintainer jonathan@wilkins.tech

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt install -y bash ca-certificates sudo zsh vim curl git tmux ctags make --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh

ENV USER root

RUN chsh -s /bin/zsh

WORKDIR /dotfiles
