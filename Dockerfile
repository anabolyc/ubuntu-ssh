# =============================================================================
FROM ubuntu:14.04.4


RUN apt-get update \
	&& apt-get install -y \
	sudo \
	openssh-server \
	openssh-client \
	python-setuptools \
	&& rm -rf /var/cache/apt/*

# -----------------------------------------------------------------------------
# Install supervisord (required to run more than a single process in a container)
# Note: EPEL package lacks /usr/bin/pidproxy
# We require supervisor-stdout to allow output of services started by
# supervisord to be easily inspected with "docker logs".
# -----------------------------------------------------------------------------
RUN easy_install 'supervisor == 3.2.0' 'supervisor-stdout == 0.1.1' \
	&& mkdir -p /var/log/supervisor/

# -----------------------------------------------------------------------------
# UTC Timezone & Networking
# -----------------------------------------------------------------------------
#RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# -----------------------------------------------------------------------------
# Configure SSH for non-root public key authentication
# -----------------------------------------------------------------------------
RUN sed -i \
	-e 's~^PasswordAuthentication yes~PasswordAuthentication no~g' \
	-e 's~^#PermitRootLogin yes~PermitRootLogin no~g' \
	-e 's~^#UseDNS yes~UseDNS no~g' \
	-e 's~^\(.*\)/usr/libexec/openssh/sftp-server$~\1internal-sftp~g' \
	/etc/ssh/sshd_config

# -----------------------------------------------------------------------------
# Enable the wheel sudoers group
# -----------------------------------------------------------------------------
RUN sed -i 's~^# %wheel\tALL=(ALL)\tALL~%wheel\tALL=(ALL) ALL~g' /etc/sudoers

# -----------------------------------------------------------------------------
# Copy files into place
# -----------------------------------------------------------------------------
ADD usr/sbin/sshd-bootstrap /usr/sbin/sshd-bootstrap
ADD etc/services-config/ssh/authorized_keys \
	etc/services-config/ssh/sshd-bootstrap.conf \
	etc/services-config/ssh/sshd-bootstrap.env \
	/etc/services-config/ssh/
ADD etc/services-config/supervisor/supervisord.conf /etc/services-config/supervisor/
ADD etc/services-config/supervisor/supervisord.d/sshd.conf \
	etc/services-config/supervisor/supervisord.d/sshd-bootstrap.conf \
	/etc/services-config/supervisor/supervisord.d/

RUN mkdir -p /etc/supervisord.d/ \
	&& cp -pf /etc/ssh/sshd_config /etc/services-config/ssh/ \
	&& ln -sf /etc/services-config/ssh/sshd_config /etc/ssh/sshd_config \
	&& ln -sf /etc/services-config/ssh/sshd-bootstrap.conf /etc/sshd-bootstrap.conf \
	&& ln -sf /etc/services-config/ssh/sshd-bootstrap.env /etc/sshd-bootstrap.env \
	&& ln -sf /etc/services-config/supervisor/supervisord.conf /etc/supervisord.conf \
	&& ln -sf /etc/services-config/supervisor/supervisord.d/sshd.conf /etc/supervisord.d/sshd.conf \
	&& ln -sf /etc/services-config/supervisor/supervisord.d/sshd-bootstrap.conf /etc/supervisord.d/sshd-bootstrap.conf \
	&& chmod +x /usr/sbin/sshd-bootstrap

# -----------------------------------------------------------------------------
# Purge
# -----------------------------------------------------------------------------
RUN rm -rf /etc/ld.so.cache \
	; rm -rf /sbin/sln \
	; rm -rf /usr/{{lib,share}/locale,share/{man,doc,info,gnome/help,cracklib,il8n},{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive} \
	; rm -rf /{root,tmp,var/cache/{ldconfig,yum}}/*

EXPOSE 22

# -----------------------------------------------------------------------------
# Set default environment variables
# -----------------------------------------------------------------------------
ENV SSH_AUTHORIZED_KEYS ""
ENV SSH_CHROOT_DIRECTORY "%h"
ENV SSH_INHERIT_ENVIRONMENT false
ENV SSH_SUDO "ALL=(ALL) ALL"
ENV SSH_USER "app-admin"
ENV SSH_USER_FORCE_SFTP false
ENV SSH_USER_HOME "/home/%u"
ENV SSH_USER_PASSWORD ""
ENV SSH_USER_PASSWORD_HASHED false
ENV SSH_USER_SHELL "/bin/bash"
ENV SSH_USER_ID "500:500"

CMD ["supervisord", "--configuration=/etc/supervisord.conf"]
