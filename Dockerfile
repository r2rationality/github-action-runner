FROM ubuntu:24.04
LABEL MAINTAINER="R2 Rationality <info@r2rationality.com>"
ENV DEBIAN_FRONTEND=noninteractive
ARG REPO

RUN mv /etc/apt/sources.list /etc/apt/sources.list.orig
RUN sed 's/archive.ubuntu.com/de.archive.ubuntu.com/g' /etc/apt/sources.list.orig > /etc/apt/sources.list
RUN apt-get update && apt-get install -y gnupg2
RUN mkdir -p /etc/apt/keyrings && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys 31F54F3E108EAD31 && \
    gpg --export 31F54F3E108EAD31 > /etc/apt/keyrings/custom.gpg
RUN apt-get install -y build-essential cmake pkg-config git zstd pv telnet whois \
        screen vim-nox dnsutils iputils-ping net-tools curl wget sudo strace \
        libboost1.83-all-dev libboost-url1.83-dev libsodium-dev libsecp256k1-dev libzstd-dev libssl-dev libfmt-dev libspdlog-dev libbotan-2-dev \
        ninja-build clang-19 clang-tools-19 docker.io && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    ln -fs /usr/share/zoneinfo/Europe/Tallinn /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata
RUN cp /etc/sudoers /etc/sudoers.orig
RUN awk '{ if (/^%sudo/) { print "%sudo\tALL=(ALL:ALL) NOPASSWD:ALL" } else { print } }' /etc/sudoers.orig > /etc/sudoers
RUN useradd -m -s /bin/bash -d /home/dev -G sudo,docker dev

USER dev
WORKDIR /home/dev
RUN mkdir actions-runner
WORKDIR /home/dev/actions-runner
RUN curl -o actions-runner-linux-x64-2.329.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz
RUN echo "194f1e1e4bd02f80b7e9633fc546084d8d4e19f3928a324d512ea53430102e1d  actions-runner-linux-x64-2.329.0.tar.gz" | shasum -a 256 -c
RUN tar xzf ./actions-runner-linux-x64-2.329.0.tar.gz
RUN --mount=type=secret,id=token,uid=1001,gid=1001 echo "Uncached step" $(date) &&  TOKEN=$(cat /run/secrets/token) && ./config.sh --url $REPO --token $TOKEN --name "dockerized-runner"
COPY start.sh /home/dev/
CMD [ "/bin/bash", "/home/dev/start.sh" ]
