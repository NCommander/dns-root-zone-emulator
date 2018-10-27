#!/bin/bash

# Handles creation of docker networks and zones
#DISABLE_CACHE="--no-cache"

echo "Deleting IDN network if it already exists"
docker network rm idn_net

docker network create \
    --ipv6 \
    --subnet=172.16.0.0/16 \
    --subnet=fd36:07b4:c298:bce5::/64 \
    --gateway=172.16.0.1 \
    --gateway=fd36:07b4:c298:bce5::1 \
    idn_net

if [ $? -ne 0 ]; then
    echo "FATAL: Unable to create Docker network zone";
    exit 1;
fi

# Switch directories and start building zones
mkdir -p build
docker build $DISABLE_CACHE -t root_zone -f instances/root_zone/Dockerfile instances

if [ $? -ne 0 ]; then
    echo "FATAL: Failed to build the root zone";
    exit 1;
fi

docker build $DISABLE_CACHE -t authoritive_internic -f instances/authoritive_internic/Dockerfile instances

if [ $? -ne 0 ]; then
    echo "FATAL: Failed to build the internic authoritive zone";
    exit 1;
fi
