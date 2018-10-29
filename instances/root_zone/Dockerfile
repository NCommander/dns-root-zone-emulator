# Grab the latest version of Ubuntu as it represents a common server env
FROM ubuntu:latest
MAINTAINER michael@casadevall.pro

# First install updates and then install BIND
RUN apt-get -y update
RUN apt-get -y dist-upgrade
RUN apt-get -y install bind9
RUN apt-get -y install nginx
RUN apt-get -y install nano

COPY ./root_zone/etc/bind/db.root_zone /etc/bind/db.root_zone
COPY ./root_zone/etc/bind/named.conf.local /etc/bind/named.conf.local
COPY ./root_zone/etc/bind/named.conf.options /etc/bind/named.conf.options
COPY ./root_zone/etc/bind/named.conf.default-zones /etc/bind/named.conf.default-zones
COPY ./root_zone/etc/bind/keys /etc/bind/keys
COPY ./common/bind.keys /etc/bind/bind.keys
COPY ./common/run_services.sh run_services.sh
CMD ./run_services.sh
