# Cloud Foundry core stack
# version 0.1
FROM tchughesiv/cf-mini-base:v205
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>

WORKDIR /root
ENV HOME /root
ENV INSTALLER_BRANCH v205
ENV NISE_DOMAIN cf.mini
ENV NISE_PASSWORD c1oudc0w

ADD run.sh /root/
ADD cleanup.sh /root/
ADD dynamic_adds.sh /root/

RUN apt-get update && apt-get -yq install dnsmasq-base && ls -lart /root/ && curl -s -k -B https://raw.githubusercontent.com/tchughesiv/cf_nise_installer/${INSTALLER_BRANCH}/scripts/bootstrap.sh > /root/bootstrap.sh && chmod u+x /root/*.sh && sed -i 's/.\/scripts\/install.sh/\/root\/dynamic_adds.sh\n.\/scripts\/install.sh\n\/root\/cleanup.sh/g' ./bootstrap.sh && ./bootstrap.sh

EXPOSE 80 443 4443
WORKDIR /root/cf_nise_installer
CMD ["/root/run.sh"]
