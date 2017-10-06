FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        vim \
        tmux \
        bc \
        cpio \
        zip \
        unzip \
        python \
        git \
        cvs \
        build-essential \
        libncurses5-dev && \
    locale-gen en_US.utf8 && \
    curl -o /root/.tmux.conf https://gist.githubusercontent.com/petrsnd/6550ee1dd04db54c4b84a44a965ba8ed/raw/eb63e4dbbefd8abf634fc978dab4e982191ef27d/.tmux.conf && \
    curl -o /root/.bashrc https://gist.githubusercontent.com/petrsnd/990e61eb3aa7b9dc272c91ac358d4797/raw/7cdae3d87e51d30be90e8fb99ad521596c32320f/.bashrc && \
    git clone https://github.com/magicmonty/bash-git-prompt.git /root/.bash-git-prompt --depth=1

COPY buildroot-common/ /root/buildroot-common
COPY rpi2-vpnrouter/ /root/rpi2-vpnrouter 
COPY rpi3-vpnrouter/ /root/rpi3-vpnrouter
COPY usb-linux/ /root/usb-linux

ENTRYPOINT ["/bin/bash"]
CMD ["-c","exec /bin/bash --rcfile <(echo '. /root/.bashrc; cd /root')"]