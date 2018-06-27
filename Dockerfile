FROM ubuntu:14.04
MAINTAINER Stefan Houtzager <stefan.houtzager@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV REFRESHED_AT 27-06-2017
ENV TERM xterm

WORKDIR /

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    wget \
    curl \
    git \
    unzip

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# erlang install
RUN echo "deb http://packages.erlang-solutions.com/ubuntu trusty contrib" >> /etc/apt/sources.list && \
    apt-key adv --fetch-keys http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && \
    apt-get -qq update && apt-get install -y \
    esl-erlang \
    esl-erlang=1:20.3 \
    build-essential \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and Install Specific Version of Elixir
WORKDIR /elixir
RUN wget -q https://github.com/elixir-lang/elixir/releases/download/v1.6.5/Precompiled.zip && \
    unzip Precompiled.zip && \
    rm -f Precompiled.zip && \
    ln -s /elixir/bin/elixirc /usr/local/bin/elixirc && \
    ln -s /elixir/bin/elixir /usr/local/bin/elixir && \
    ln -s /elixir/bin/mix /usr/local/bin/mix && \
    ln -s /elixir/bin/iex /usr/local/bin/iex

WORKDIR /

# install Node.js (>= 5.0.0) and NPM in order to satisfy brunch.io dependencies
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - && apt-get -y install nodejs inotify-tools

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

RUN apt-get install -y \
    python-numpy \
    software-properties-common \
    libsecret-1-0 \
    gnome-keyring

RUN apt-get install -y --force-yes --no-install-recommends supervisor \
    openssh-server \
    pwgen \
    sudo \
    vim-tiny \
    net-tools \
    lxde \
    x11vnc \
    xvfb \
    gtk2-engines-murrine \
    ttf-ubuntu-font-family \
    libreoffice \
    firefox \
    xserver-xorg-video-dummy \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/startup.aux/
RUN echo "#Dummy" > /etc/startup.aux/00.sh
RUN chmod +x /etc/startup.aux/00.sh
RUN mkdir -p /etc/supervisor/conf.d
RUN rm /etc/supervisor/supervisord.conf

# create an ubuntu user who cannot sudo
# RUN useradd --create-home --shell /bin/bash --user-group ubuntu
RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu
RUN echo "ubuntu:badpassword" | chpasswd
ADD elixir-dev-anywhere-docker/startup.sh /
ADD elixir-dev-anywhere-docker/supervisord.conf.xorg /etc/supervisor/supervisord.conf
ADD elixir-dev-anywhere-docker/openbox-config /openbox-config
RUN cp -r /openbox-config/.config ~ubuntu/
RUN chown -R ubuntu ~ubuntu/.config ; chgrp -R ubuntu ~ubuntu/.config
RUN rm -r /openbox-config

ENV HOME=/home/ubuntu

# Install phoenix, local Elixir hex and rebar (in ENV HOME)
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

# intellij
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update -qq && \
    echo 'Installing OS dependencies' && \
    apt-get install -qq -y --fix-missing sudo software-properties-common libxext-dev libxrender-dev libxslt1.1 \
        libxtst-dev libgtk2.0-0 libcanberra-gtk-module && \
    echo 'Cleaning up' && \
    apt-get clean -qq -y && \
    apt-get autoclean -qq -y && \
    apt-get autoremove -qq -y &&  \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN mkdir -p /home/ubuntu/.IdeaIC2017.3/config/options && \
    mkdir -p /home/ubuntu/.IdeaIC2017.3/config/plugins

ADD elixir-dev-anywhere-docker/jdk.table.xml /home/ubuntu/.IdeaIC2017.3/config/options/jdk.table.xml
ADD elixir-dev-anywhere-docker/jdk.table.xml /home/ubuntu/.jdk.table.xml
ADD elixir-dev-anywhere-docker/intellij/run /usr/local/bin/intellij
ADD elixir-dev-anywhere-docker/intellij-elixir.zip /home/ubuntu/.IdeaIC2017.3/config/plugins/intellij-elixir.zip

RUN chmod +x /usr/local/bin/intellij

RUN echo 'Downloading IntelliJ IDEA' && \
    wget https://download.jetbrains.com/idea/ideaIC-2017.3.5.tar.gz -O /tmp/intellij.tar.gz -q && \
    echo 'Installing IntelliJ IDEA' && \
    mkdir -p /opt/intellij && \
    tar -xf /tmp/intellij.tar.gz --strip-components=1 -C /opt/intellij && \
    rm /tmp/intellij.tar.gz

RUN echo 'Installing Elixir plugin' && \
    cd /home/ubuntu/.IdeaIC2017.3/config/plugins/ && \
    unzip -q intellij-elixir.zip && \
    rm intellij-elixir.zip

# noVNC
ADD elixir-dev-anywhere-docker/noVNC /noVNC/
# store a password for the VNC service
RUN mkdir /home/root
RUN mkdir /home/root/.vnc
RUN x11vnc -storepasswd badpassword /home/root/.vnc/passwd
ADD elixir-dev-anywhere-docker/xorg.conf /etc/X11/xorg.conf

# pgadmin3 and nano
# prerequisites to install a new version of pgadmin3 https://undebugable.wordpress.com/2016/01/11/pgadmin-3-warning-the-server-you-are-connecting-to-is-not-a-version-that-is-supported-by-this-release/

# add the repository
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# install their key
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get install -y \
    nano \
    postgresql-client \
    pgadmin3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/startup.sh"]
