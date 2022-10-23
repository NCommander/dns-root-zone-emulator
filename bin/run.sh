#!/bin/bash

DELETE_OPTION="--rm"
docker network rm idn_net

docker network create \
    --ipv6 \
    --subnet=172.16.0.0/16 \
    --subnet=fd36:07b4:c298:bce5::/64 \
    --gateway=172.16.0.1 \
    --gateway=fd36:07b4:c298:bce5::1 \
    idn_net

# Root zone server
docker run -d --net idn_net \
              --name root_zone \
              --ip 172.16.0.100 \
              --ip6 fd36:07b4:c298:bce5::1000  \
              --hostname cadimus.nynex.internic \
              --init $DELETE_OPTION root_zone

# Authoritive root zone
docker run -d --net idn_net \
              --name authoritive_internic \
              --ip 172.16.0.101 \
              --ip6 fd36:07b4:c298:bce5::1001 \
              --dns 127.0.0.1 \
              --hostname aethena.nynex.internic \
              --init $DELETE_OPTION authoritive_internic

# nynex.internic second level domain
docker run -d --net idn_net \
              --name authoritive_nynex.internic \
              --ip 172.16.0.102 \
              --ip6 fd36:07b4:c298:bce5::1002 \
              --dns 127.0.0.1 \
              --hostname olpymus.nynex.internic \
              --init $DELETE_OPTION authoritive_nynex.internic

# nynex.internic recursive resolver
docker run -d --net idn_net \
              --name recursive_nynex.internic \
              --ip 172.16.0.103 \
              --ip6 fd36:07b4:c298:bce5::1003 \
              --dns 127.0.0.1 \
              --hostname hermes.nynex.internic \
              --init $DELETE_OPTION recursive_nynex.internic

# nynex.internic recursive resolver
docker run -d --net idn_net \
              --name recursive_nynex.internic \
              --ip 172.16.0.103 \
              --ip6 fd36:07b4:c298:bce5::1003 \
              --dns 127.0.0.1 \
              --hostname hermes.nynex.internic \
              --init $DELETE_OPTION recursive_nynex.internic

# nynex.internic recursive resolver
 docker run -d --net idn_net \
              --name client_nynex \
              --ip 172.16.0.200 \
              --ip6 fd36:07b4:c298:bce5::2000 \
              --dns 172.16.0.103 \
              --init $DELETE_OPTION client_nynex
