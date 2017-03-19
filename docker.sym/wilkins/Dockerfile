# Set up a temp environment with my dotfile setup, in a container
# Usage:
#       docker run -it wilkins:latest
#       run bootstrap.sh && source ~/.zshrc

FROM ubuntu:latest

# update and install zsh, git, vim, curl
RUN apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y zsh git vim curl

# install zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh \
        && chsh -s /bin/zsh

# grab my dotfiles
RUN git clone https://github.com/W1lkins/dotfiles.git /root/dotfiles

# start zsh in /root/dotfiles
WORKDIR /root/dotfiles
ENV SHELL /usr/bin/zsh
ENTRYPOINT /usr/bin/zsh
