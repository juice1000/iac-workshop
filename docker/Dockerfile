# Linux-"Server" fuer die Labs: Ubuntu 24.04 mit systemd und SSH.
# Verhaelt sich fuer Ansible wie eine kleine VM.
FROM ubuntu:24.04

ENV container=docker DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      systemd systemd-sysv openssh-server python3 sudo acl \
      ca-certificates iproute2 \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /root/.ssh && chmod 700 /root/.ssh \
 && systemctl enable ssh.service \
 && systemctl mask systemd-firstboot.service getty.target console-getty.service

# Wie in den offiziellen Docker-Images: Dienste starten bei der Paketinstallation
# nicht automatisch. Ansible startet sie gezielt, nachdem die Konfiguration steht.
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d \
 && chmod +x /usr/sbin/policy-rc.d

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
