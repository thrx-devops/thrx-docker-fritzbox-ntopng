FROM ubuntu:16.04
MAINTAINER Thrx De <coder@thrx.de>

# Set environment
ENV LANG en_US.UTF-8
ENV TERM xterm

RUN apt-get update
RUN apt-get -y -q install curl lsb-release
RUN curl -s --remote-name http://packages.ntop.org/apt/16.04/all/apt-ntop-stable.deb
RUN dpkg -i apt-ntop-stable.deb
RUN rm -rf apt-ntop-stable.deb

RUN apt-get update
RUN apt-get -y -q install ntopng redis-server libpcap0.8 libmysqlclient-dev

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set workdir (fix missing pid directory)
WORKDIR /run/ntopng

# Copy configuration files
COPY fritzdump.sh /

# Prepare NTOPNG start
RUN chmod 755 /fritzdump.sh

# Expose NTOPNG standard http port
EXPOSE 3000/tcp

# Start NTOPNG
CMD ["/fritzdump.sh"]
