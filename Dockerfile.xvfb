FROM ubuntu:14.04
MAINTAINER Mark McCahill <mccahill@duke.edu>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# setup our Ubuntu sources (ADD breaks caching)
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main restricted universe multiverse\n\
deb http://archive.ubuntu.com/ubuntu trusty-updates main restricted universe multiverse\n\
deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse\n\ 
deb http://security.ubuntu.com/ubuntu trusty-security main restricted universe multiverse \n\
"> /etc/apt/sources.list

# no Upstart or DBus
# https://github.com/dotcloud/docker/issues/1724#issuecomment-26294856
RUN apt-mark hold initscripts udev plymouth mountall
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl
RUN apt-get update \
    && apt-get upgrade -y

RUN apt-get install -y python-numpy
RUN apt-get install -y software-properties-common wget
RUN apt-get install -y --force-yes --no-install-recommends supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/startup.aux/
RUN echo "#Dummy" > /etc/startup.aux/00.sh
RUN chmod +x /etc/startup.aux/00.sh
RUN mkdir -p /etc/supervisor/conf.d
RUN rm /etc/supervisor/supervisord.conf

# create an ubuntu user
#PASS=`pwgen -c -n -1 10`
#PASS=ubuntu
#echo "User: ubuntu Pass: $PASS"
#RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu

# create an ubuntu user who cannot sudo
RUN useradd --create-home --shell /bin/bash --user-group ubuntu
RUN echo "ubuntu:badpassword" | chpasswd

ADD startup.sh /
ADD supervisord.conf.xorg /etc/supervisor/supervisord.conf
EXPOSE 6080
EXPOSE 5900
EXPOSE 22

ADD openbox-config /openbox-config
RUN cp -r /openbox-config/.config ~ubuntu/
RUN chown -R ubuntu ~ubuntu/.config ; chgrp -R ubuntu ~ubuntu/.config
RUN rm -r /openbox-config

WORKDIR /

############ being Eclipse stuff ###############
# java install
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
# say yes to the oracle license agreement
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
#
RUN apt-get install -y --force-yes oracle-java8-installer
RUN apt-get install -y --force-yes oracle-java8-set-default
#
# eclipse IDE
RUN apt-get install -y desktop-file-utils
RUN apt-get install -y eclipse
############ end Eclipse stuff ###############

# noVNC
ADD noVNC /noVNC/
# store a password for the VNC service
RUN mkdir /home/root
RUN mkdir /home/root/.vnc
RUN x11vnc -storepasswd foobar /home/root/.vnc/passwd

ENTRYPOINT ["/startup.sh"]
