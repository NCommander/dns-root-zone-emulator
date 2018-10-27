# Grab the latest version of Ubuntu as it represents a common server env
FROM ubuntu:latest
MAINTAINER michael@casadevall.pro

# First install updates and then install BIND
RUN apt-get -y update
RUN apt-get -y dist-upgrade
RUN apt-get -y install bind9
RUN apt-get -y install nginx

COPY ./etc/bind/db.internic /etc/bind/db.internic
COPY ./etc/bind/named.conf.local /etc/bind/named.conf.local
COPY ./run_services.sh run_services.sh
CMD ./run_services.sh
