#!/bin/bash

# Configure SSH
/bin/bash /usr/sbin/sshd-bootstrap

# Run SSH
/usr/sbin/sshd -D -p 443
