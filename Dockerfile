FROM ubuntu:24.04
LABEL maintainer="R2 Rationality <info@r2rationality.com>"

ENV DEBIAN_FRONTEND=noninteractive

ARG RUNNER_VERSION=2.329.0
ARG RUNNER_CHECKSUM=194f1e1e4bd02f80b7e9633fc546084d8d4e19f3928a324d512ea53430102e1d
ARG APT_MIRROR=archive.ubuntu.com
ARG DEV_UID=1001
ARG DEV_GID=1001

RUN mv /etc/apt/sources.list /etc/apt/sources.list.orig && \
    sed "s/archive.ubuntu.com/${APT_MIRROR}/g" /etc/apt/sources.list.orig \
        > /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl git sudo docker.io tzdata libicu74 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    ln -fs /usr/share/zoneinfo/Europe/Tallinn /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

RUN cp /etc/sudoers /etc/sudoers.orig && \
    echo "dev ALL=(ALL) NOPASSWD: /usr/bin/chown root\:docker /var/run/docker.sock" >> /etc/sudoers && \
    echo "dev ALL=(ALL) NOPASSWD: /home/dev/actions-runner/bin/installdependencies.sh" >> /etc/sudoers && \
    visudo -c

RUN groupadd -g ${DEV_GID} dev && \
    useradd -m -u ${DEV_UID} -g ${DEV_GID} -s /bin/bash -d /home/dev \
            -G sudo,docker dev

USER dev
WORKDIR /home/dev/actions-runner

RUN curl -fsSL -o runner.tar.gz \
        "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" && \
    echo "${RUNNER_CHECKSUM}  runner.tar.gz" | shasum -a 256 -c && \
    tar xzf runner.tar.gz && \
    rm runner.tar.gz

USER root
RUN /home/dev/actions-runner/bin/installdependencies.sh && \
    echo '#!/bin/bash' > /home/dev/actions-runner/bin/installdependencies.sh && \
    echo 'echo "Dependencies already installed at build time, skipping."' >> /home/dev/actions-runner/bin/installdependencies.sh
USER dev
COPY --chown=dev:dev start.sh /home/dev/start.sh
RUN chmod +x /home/dev/start.sh

CMD ["/bin/bash", "/home/dev/start.sh"]