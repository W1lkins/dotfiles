FROM debian:buster-slim

LABEL maintainer jonathan@wilkins.tech

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt install -y bash pkg-config ca-certificates sudo zsh vim unzip automake libtool libtool-bin gettext curl git tmux ctags make gnupg2 lsb-release cmake build-essential ssh --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV USER root

RUN chsh -s /bin/zsh

WORKDIR /dotfiles
