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

# Install markdown linter: https://github.com/markdownlint/markdownlint
# consecutive `RUN` commands intentional
COPY ./gemrc /tmp/gemrc
RUN gem install mdl:0.11.0 --config-file=/tmp/gemrc

# Install docker linter: https://github.com/hadolint/hadolint
ENV HADOLINT_URL https://github.com/hadolint/hadolint/releases/download/v2.10.0/hadolint-Linux-x86_64
RUN wget $HADOLINT_URL \
        --progress=dot:giga \
        --output-document /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint

ENTRYPOINT [ "/bin/sh", "-c" ]
