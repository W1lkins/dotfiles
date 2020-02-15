FROM debian:buster-slim

LABEL maintainer jonathan@wilkins.tech

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt install -y bash pkg-config ca-certificates sudo zsh vim unzip automake libtool libtool-bin gettext curl git tmux ctags make gnupg2 lsb-release cmake build-essential ssh locales --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8    

RUN useradd --create-home wilkins --groups sudo && echo "wilkins:docker" | chpasswd
RUN chsh -s /bin/zsh

USER wilkins
ENV USER wilkins
WORKDIR /home/wilkins/.dotfiles
