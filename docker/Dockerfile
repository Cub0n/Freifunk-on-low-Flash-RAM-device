FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade && apt-get install -y --no-install-recommends \
    ca-certificates \
    file \
    git \
    subversion \
    python3 \
    build-essential g++ bash make patch \
    gawk \
    unzip \
    libncurses5 libncurses5-dev \
    libssl-dev \
    libelf-dev \
    wget \
    rsync \
    time \
    ecdsautils \
    lua-check \
    shellcheck \
    flex xz-utils python3-distutils-extra \
    curl libsnmp-dev liblzma-dev \
    libpam0g-dev cpio libc6 \
    python3-distutils \
    openssh-client python2.7 nano \
    ccache \
    clang \
    gcc-multilib \
    gettext \
    libdw-dev \
    locales \
    pv \
    pwgen \
    python \
    python3-pip \
    qemu-utils \
    signify-openbsd \
    sudo \
    swig \
    zlib1g-dev \
  && apt-get -y autoremove \
  && apt-get clean

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN useradd -d /gluon gluon
USER gluon

VOLUME /gluon
WORKDIR /gluon
