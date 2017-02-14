FROM ubuntu:16.04

CMD apt-get update && \
    apt-get install \
        curl \
        wget \
        vim \
        bc \
        cpio \
        zip \
        unzip \
        python \
        git \
        build-essential \
        libncurses5-dev
