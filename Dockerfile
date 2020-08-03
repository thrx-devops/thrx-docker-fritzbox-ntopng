FROM ubuntu:18.04
#FROM ubuntu:16.04
MAINTAINER Thrx De <coder@thrx.de>

# Set environment
ENV DEBIAN_FRONTEND noninteractive

# Pass --build-arg TZ=<YOUR_TZ> when running docker build to override this.
ARG TZ=Germany/Berlin

#ENV LANGUAGE en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LC_ALL en_US.UTF-8
#RUN locale-gen en_US.UTF-8
#RUN dpkg-reconfigure locales
#ENV TERM xterm

RUN apt-get update
RUN apt-get -y -q install curl wget lsb-release gnupg tzdata perl libdigest-md5-perl redis-server libpcap0.8 libmysqlclient-dev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD http://apt-stable.ntop.org/18.04/all/apt-ntop-stable.deb .
#ADD http://apt-stable.ntop.org/16.04/all/apt-ntop-stable.deb .
RUN dpkg -i apt-ntop-stable.deb
RUN rm -rf apt-ntop-stable.deb
RUN apt-get update && apt-get -y install ntopng

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set workdir (fix missing pid directory)
WORKDIR /run/ntopng

# Copy configuration files
COPY scripts /

# Prepare NTOPNG start
RUN chmod 755 /fritzdump.sh

# Expose NTOPNG standard http port
EXPOSE 3000/tcp

# Start NTOPNG
CMD ["/fritzdump.sh"]
