FROM ubuntu:12.04.5

RUN apt-get -y install curl dnsmasq git
RUN sed -i 's/^mesg n/tty -s \&\& mesg n/g' /root/.profile
ADD ./README.md
