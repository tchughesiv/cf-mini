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
RUN mkdir /root/cf_nise_installer/test_apps && mkdir /root/cf_nise_installer/test_apps/spring-music && mkdir /root/cf_nise_installer/test_apps/cf-env
ADD cf-env /root/cf_nise_installer/test_apps/cf-env/
ADD spring-music /root/cf_nise_installer/test_apps/spring-music/
RUN chmod u+x /root/*.sh && sed -i '/bundle install/d' /root/cf_nise_installer/scripts/install_cf_release.sh && wget -O /root/cf-cli_amd64.deb "https://cli.run.pivotal.io/stable?release=debian64&version=6.11.2&source=github-rel cf-cli_amd64.deb" && dpkg -i /root/cf-cli_amd64.deb && rm /root/cf-cli_amd64.deb

EXPOSE 80 443 4443
CMD ["/root/run.sh"]
