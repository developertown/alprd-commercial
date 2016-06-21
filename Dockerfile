FROM ubuntu:14.04

RUN apt-get update && apt-get -y upgrade

RUN \
     apt-get -y install wget \
  && wget -O - http://deb.openalpr.com/openalpr.gpg.key \
   | apt-key add - \
  && echo "deb http://deb.openalpr.com/commercial/ trusty main" >> /etc/apt/sources.list.d/openalpr.list \
  && apt-get update && sudo apt-get -y install openalpr openalpr-daemon

VOLUME ["/data/plates/images"]

RUN apt-get -y install python

COPY update_config.sh /
COPY alprd.conf.template /

ENTRYPOINT ["/update_config.sh"]
CMD ["/usr/bin/alprd", "-ft"]
