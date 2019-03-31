FROM ubuntu:16.04
MAINTAINER Thrx De <coder@thrx.de>

# Set environment
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales
ENV TERM xterm

RUN apt-get update
RUN apt-get -y -q install curl lsb-release perl libdigest-md5-perl ntopng redis-server libpcap0.8 libmysqlclient-dev
ADD http://apt-stable.ntop.org/16.04/all/apt-ntop-stable.deb .
RUN dpkg -i apt-ntop-stable.deb
# RUN rm -rf apt-ntop-stable.deb

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
