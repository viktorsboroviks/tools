# ubuntu 22.04
FROM ubuntu:jammy-20220815

ARG DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        make=4.3-4.1build1 \
        python3-pip=22.0.2+dfsg-1 \
        wget=1.21.2-2ubuntu1 \
        ruby=1:3.0~exp1 \
        # linters
        cppcheck=2.7-1 \
        chktex=1.7.6-4 \
        lacheck=1.26-17 \
        shellcheck=0.8.0-2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip3 install \
        --no-cache-dir \
        --requirement /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# install markdown linter: https://github.com/markdownlint/markdownlint
# consecutive `RUN` commands intentional
COPY ./gemrc /tmp/gemrc
RUN gem install mdl:0.11.0 --config-file=/tmp/gemrc

# hadolint
# official build segfaults when running in x64 docker on m2 arm,
# see: https://github.com/hadolint/hadolint/issues/823
# so it is built here
# ref: https://github.com/hadolint/hadolint/issues/904
# dependencies for hadolint are separated from others to make it easier to
# remove them in the future
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        # needed to download hadolint
        git=1:2.34.1-1ubuntu1.5 \
        # needed to download ghcup
        curl=7.81.0-1ubuntu1.7 \
        # ghcup minimal requirements from https://www.haskell.org/ghcup/install/
        build-essential=12.9ubuntu3 \
        libffi-dev=3.4.2-4 \
        libgmp-dev=2:6.2.1+dfsg-3ubuntu1 \
        libgmp10=2:6.2.1+dfsg-3ubuntu1 \
        libncurses-dev=6.3-2 \
        libncurses5=6.3-2 \
        libtinfo5=6.3-2 \
        # needed by ghcup
        libnuma-dev=2.0.14-3ubuntu2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ref: https://www.haskell.org/ghcup/
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
    BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
    BOOTSTRAP_HASKELL_GHC_VERSION=9.2.5 \
    BOOTSTRAP_HASKELL_CABAL_VERSION=latest \
    BOOTSTRAP_HASKELL_ADJUST_BASHRC=P \
    sh

RUN git clone https://github.com/hadolint/hadolint

# changing cd to WORKDIR here is an overkill, we also dont know the
# default WORKDIR of the used image
# hadolint ignore=DL3003,SC1091
RUN . /root/.ghcup/env \
    && cd hadolint \
    && git checkout v2.12.0 \
    && cabal configure \
    && cabal build --minimize-conflict-set \
    && cabal install --installdir=/usr/bin

# when this bug is fixed, we can get back to downloading the official release
## Install docker linter: https://github.com/hadolint/hadolint
#ENV HADOLINT_URL https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64
#RUN wget $HADOLINT_URL \
#        --progress=dot:giga \
#        --output-document /usr/local/bin/hadolint \
#    && chmod +x /usr/local/bin/hadolint

ENTRYPOINT [ "/bin/sh", "-c" ]
