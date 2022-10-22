# Grab the latest version of Ubuntu as it represents a common server env
FROM ubuntu:latest
MAINTAINER michael@casadevall.pro

# First install updates and then install BIND
RUN apt-get -y update
RUN apt-get -y dist-upgrade
RUN apt-get -y install nano
RUN apt-get -y install bind9
RUN apt-get -y install nginx

COPY ./common/db.root /etc/bind/db.root
COPY ./common/bind.keys /etc/bind/bind.keys
COPY ./common/run_services.sh run_services.sh

COPY ./recursive_nynex.internic/etc/bind/named.conf.options /etc/bind/named.conf.options
COPY ./recursive_nynex.internic/etc/bind/named.conf.default-zones /etc/bind/named.conf.default-zones

CMD ./run_services.sh
