#!/bin/bash

source build.conf

docker run --name ssh-server-instance-dev --rm -ti \
 	-p 8022:8022 \
    --env SSH_AUTHORIZED_KEYS="ssh-rsa {key-value-here} dronische@ubuntu-laptop" \
 	${DOCKER_IMAGE_REPOSITORY_NAME} 
