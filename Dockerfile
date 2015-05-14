FROM ubuntu:12.04.5

RUN apt-get update && apt-get -yq install curl dnsmasq-base git && rm -rf /var/lib/apt/lists/*
RUN sed -i 's/^mesg n/tty -s \&\& mesg n/g' /root/.profile
ADD ./README.md ~/
