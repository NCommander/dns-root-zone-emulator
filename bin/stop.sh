#!/bin/bash
echo "Shuting down zones"
docker stop root_zone
docker stop authoritive_internic
docker stop authoritive_nynex.internic
docker stop recursive_nynex.internic
docker stop client_nynex