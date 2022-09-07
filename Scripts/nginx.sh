#!/bin/bash
apt-get update
apt-get install -y curl wget
curl -fsSL https://get.docker.com | bash
docker swarm init
docker service create -p 80:80 --name nginx

# # sleep until instance is ready
# until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
#   sleep 1
# done

# # install nginx
# apt-get update
# apt-get -y install nginx

# # make sure nginx is started
# service nginx start