#!/bin/bash

source build.conf

docker run --name ssh-server-instance-dev --rm -ti \
 	-p 8022:443 \
    --env SSH_AUTHORIZED_KEYS="ssh-rsa {pub-key-value-here}" \
 	${DOCKER_IMAGE_REPOSITORY_NAME} 
