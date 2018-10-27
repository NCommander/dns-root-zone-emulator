#!/bin/bash

DELETE_OPTION="--rm"

# Root zone server
docker run -d --net idn_net --name root_zone --ip 172.16.0.100 --ip6 fd36:07b4:c298:bce5::1000 --init $DELETE_OPTION root_zone

# Authoritive root zone
docker run -d --net idn_net --name authoritive_internic --ip 172.16.0.101 --ip6 fd36:07b4:c298:bce5::1001 --dns 172.16.0.100 --init authoritive_internic
