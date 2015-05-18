# Cloud Foundry running stack
# version 0.1
FROM tchughesiv/cf-mini-release:v205
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>

WORKDIR /root
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

ENV HOME /root
ENV INSTALLER_BRANCH v205
ENV NISE_DOMAIN cf.mini
ENV NISE_PASSWORD c1oudc0w

ADD run.sh /root/
RUN chmod u+x /root/*.sh && sed -i '/bundle install/d' /root/cf_nise_installer/scripts/install_cf_release.sh

EXPOSE 80 443 4443
CMD ["/root/run.sh"]
