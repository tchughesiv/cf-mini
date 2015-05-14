# Cloud Foundry core stack
# version 0.1
FROM ubuntu:12.04.5
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>

USER root

RUN apt-get update && apt-get -yq install curl dnsmasq-base
RUN sed -i 's/^mesg n/tty -s \&\& mesg n/g' /root/.profile
ADD ./README.md ~/
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

USER docker

ENV INSTALLER_BRANCH=v205
ENV NISE_DOMAIN=cf.mini
ENV NISE_PASSWORD=c1oudc0w
RUN curl -s -k -B https://raw.githubusercontent.com/yudai/cf_nise_installer/${INSTALLER_BRANCH}/scripts/bootstrap.sh > /home/docker/bootstrap.sh && chmod u+x /home/docker/bootstrap.sh && cd ~/ && /home/docker/bootstrap.sh 

USER root

RUN rm -rf /var/lib/apt/lists/*