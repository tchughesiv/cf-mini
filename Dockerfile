# Cloud Foundry running stack
# version 0.2
FROM tchughesiv/cf-mini-release:v215
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>

WORKDIR /root
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

ENV HOME /root
ENV INSTALLER_BRANCH v215
ENV NISE_DOMAIN cf-mini.example
ENV NISE_PASSWORD c1oudc0w

RUN mkdir /root/cf_nise_installer/test_apps && mkdir /root/cf_nise_installer/test_apps/spring-music && mkdir /root/cf_nise_installer/test_apps/cf-env && mkdir /root/cf_nise_installer/test_apps/test_app && rm -rf /root/cf_nise_installer/test_app && rm -f /etc/supervisor/conf.d/supervisord.conf
ADD cf-env /root/cf_nise_installer/test_apps/cf-env/
ADD spring-music /root/cf_nise_installer/test_apps/spring-music/
ADD test_app /root/cf_nise_installer/test_apps/test_app/
ADD supervisord.conf /etc/supervisor/conf.d/
ADD run.sh /root/
ADD monit_daemon.sh /root/
ADD run_first.sh /root/
RUN chmod u+x /root/*.sh && sed -i '/bundle install/d' /root/cf_nise_installer/scripts/install_cf_release.sh && wget -O /root/cf-cli_amd64.deb "https://cli.run.pivotal.io/stable?release=debian64&version=6.12.3&source=github-rel cf-cli_amd64.deb" && dpkg -i /root/cf-cli_amd64.deb && rm /root/cf-cli_amd64.deb

WORKDIR /var/vcap/packages/cloud_controller_ng/cloud_controller_ng/
RUN find . -type f -name "Gemfile*" | xargs sed -i '/pg/ s/0.16.0/0.17.1/g' && find . -type f -name "Gemfile*" | xargs sed -i '/eventmachine/ s/1.0.3/1.0.4/g' && find . -type f -name "Gemfile*" | xargs sed -i '/delayed_job/ s/4.0.4/4.0.6/g' && /var/vcap/packages/ruby-2.1.6/bin/bundle install && /var/vcap/packages/ruby-2.1.6/bin/bundle clean

WORKDIR /root/cf_nise_installer/test_apps
EXPOSE 80 443 4443
CMD /root/run_first.sh ; /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf & /root/run.sh
