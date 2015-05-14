# Cloud Foundry core stack
# version 0.1
FROM ubuntu:12.04.5
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>

RUN apt-get update && apt-get -yq install curl dnsmasq-base sudo
RUN sed -i 's/^mesg n/tty -s \&\& mesg n/g' /root/.profile
ADD ./README.md ./dynamic_adds.sh /root/

ENV INSTALLER_BRANCH=v205
ENV NISE_DOMAIN=cf.mini
ENV NISE_PASSWORD=c1oudc0w
RUN curl -s -k -B https://raw.githubusercontent.com/yudai/cf_nise_installer/${INSTALLER_BRANCH}/scripts/bootstrap.sh > /root/bootstrap.sh && chmod u+x /root/bootstrap.sh /root/dynamic_adds.sh

WORKDIR /root
RUN sed -i 's/.\/scripts\/install.sh/~\/dynamic_adds.sh\n.\/scripts\/install.sh/g' ./bootstrap.sh
RUN ./bootstrap.sh

RUN rm -rf /var/lib/apt/lists/* /var/vcap/data/packages/rootfs_cflinuxfs2 /var/vcap/data/packages/buildpack_go /var/vcap/data/packages/buildpack_java /var/vcap/data/packages/buildpack_php /var/vcap/data/packages/buildpack_python

EXPOSE 80 443 4443
WORKDIR /root/cf_nise_installer
CMD ["/etc/init.d/dnsmasq restart && ./scripts/start.sh"]
