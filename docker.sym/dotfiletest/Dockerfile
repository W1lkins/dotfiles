FROM ubuntu

ARG APT_PROXY
ARG APT_PROXY_SSL

# install programs
RUN set -ex \
    && if [ -n "$APT_PROXY" ]; then echo "Acquire::http { Proxy \"http://${APT_PROXY}\"; };" > /etc/apt/apt.conf.d/00proxy; fi \
    && if [ -n "$APT_PROXY_SSL" ]; then echo "Acquire::https { Proxy \"https://${APT_PROXY_SSL}\"; };" > /etc/apt/apt.conf.d/00proxy; fi \
    && apt -y update \
    && apt -y install \
        rsync \
        sudo \
        zsh \
        vim \
        curl \
        git \
        shellcheck

# install zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh && chsh -s /bin/zsh

WORKDIR /project
