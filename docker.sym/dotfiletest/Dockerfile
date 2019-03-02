FROM debian:buster-slim

LABEL maintainer jonathan@wilkins.tech

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt install -y bash ca-certificates sudo zsh vim curl git tmux ctags make gnupg2 lsb-release --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV USER root

RUN chsh -s /bin/zsh

WORKDIR /dotfiles
