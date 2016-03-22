#!/bin/bash

# Configure SSH
/usr/sbin/sshd-bootstrap

# Run SSH
/usr/sbin/sshd -D
