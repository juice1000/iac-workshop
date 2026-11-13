# Linux-"Server" fuer die Labs: Ubuntu 24.04 mit systemd und SSH.
# Verhaelt sich fuer Ansible wie eine kleine VM.
# Das Image ist der "leere Server". Es enthaelt nur, was jeder Server hat, und noch keine Anwendung.
FROM ubuntu:24.04

ENV container=docker DEBIAN_FRONTEND=noninteractive

# Pakete:
#   systemd, systemd-sysv   init-System, damit Dienste wie auf einer VM starten, stoppen und beim Booten laufen
#   openssh-server          damit Ansible sich per SSH anmelden kann
#   python3                 Ansible-Module laufen als Python-Skripte auf dem Server
#   sudo, acl               Ansible braucht sie fuer become, auch fuer Benutzer wie postgres
#   ca-certificates         HTTPS-Zertifikate, z. B. fuer apt
#   iproute2                Netzwerkwerkzeuge zum Nachsehen (ip addr)
# Der Rest raeumt auf (kleineres Image), legt /root/.ssh an, aktiviert ssh und schaltet Dienste ab, die im
# Container sinnlos sind (Konsole, Erststart).
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

# Wie in einer VM soll systemd das Kommando zum Beenden verstehen: SIGRTMIN+3 faehrt systemd sauber herunter.
# CMD startet systemd als erstes Programm (PID 1), danach laufen ssh und alle weiteren Dienste.
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
