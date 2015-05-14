FROM ubuntu:12.04.5

RUN apt-get update && apt-get -yq install curl dnsmasq-base
RUN sed -i 's/^mesg n/tty -s \&\& mesg n/g' /root/.profile
ADD ./README.md ~/
RUN export INSTALLER_BRANCH=v205 ; export NISE_DOMAIN=cf.mini ; export NISE_PASSWORD=c1oudc0w ; bash < <(curl -s -k -B https://raw.githubusercontent.com/yudai/cf_nise_installer/${INSTALLER_BRANCH:-master}/scripts/bootstrap.sh)

RUN rm -rf /var/lib/apt/lists/*