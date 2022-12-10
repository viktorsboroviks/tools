# ubuntu 20.04
FROM ubuntu:focal-20211006

# set timezone to prevent tzdata installation from hanging on TZ prompt
ENV TZ=Europe/Riga
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

ARG DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        # latex
        texlive-latex-extra=2019.202000218-1 \
        # svg to pdf conversion
        inkscape=0.92.5-1ubuntu1.1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/bin/sh", "-c" ]
