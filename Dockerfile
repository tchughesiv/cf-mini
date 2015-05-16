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

RUN /root/insert.sh

EXPOSE 80 443 4443

ENTRYPOINT 
CMD ["/root/run.sh"]
