# Cloud Foundry running stack
# version 0.1
FROM tchughesiv/cf-mini-release:v205
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>

WORKDIR /root
ENV HOME /root
ENV NISE_DOMAIN cf.mini

ADD run.sh /root/
ADD insert.sh /root/
RUN chmod u+x /root/*.sh

RUN /root/insert.sh

EXPOSE 80 443 4443
CMD ["/root/run.sh"]
