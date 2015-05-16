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
ENV NISE_DOMAIN cf.mini

ADD run.sh /root/
ADD insert.sh /root/
RUN chmod u+x /root/*.sh

RUN /root/insert.sh && sed -i "s/grep -q '\/instance' \/proc\/self\/cgroup/grep -q '\/docker' \/proc\/self\/cgroup/g" /var/vcap/packages/common/utils.sh && sed -i "s/grep -q '\/instance' \/proc\/self\/cgroup/grep -q '\/docker' \/proc\/self\/cgroup/g" ./data/jobs/dea_logging_agent/4d4a96b62bea490993fc8c25f04032133815c152/d8128cbfe98ef358ccc5a91e7642edda1ab5d54f/templates/gorouter_ctl.erb

EXPOSE 80 443 4443
CMD ["/root/run.sh"]
