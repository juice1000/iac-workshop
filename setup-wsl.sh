#!/usr/bin/env bash
# Einrichtung der Lernumgebung in Ubuntu 24.04 unter WSL2 (Windows).
# Installiert Docker, Ansible und Terraform und prueft am Ende alles mit lab00-check.
# Mehrfaches Ausfuehren ist ungefaehrlich: was schon da ist, wird uebersprungen.
#
# Aufruf im Ordner des Repositorys (in Ubuntu, nicht in PowerShell):
#   bash setup-wsl.sh
set -euo pipefail

cd "$(dirname "$0")" || exit 1

NR=0

schritt() {
  NR=$((NR + 1))
  printf '\n===== Schritt %s: %s\n' "$NR" "$*"
}

fehler() {
  printf '\nFEHLER: %s\n' "$*" >&2
  exit 1
}

# Bei einem unerwarteten Abbruch zeigen, wo es hakt
trap 'printf "\nAbbruch in Zeile %s. Bitte die Ausgabe darueber kopieren und der Trainerin oder dem Trainer zeigen.\n" "$LINENO" >&2' ERR

schritt "Umgebung pruefen"

if [ "$(id -u)" -eq 0 ]; then
  fehler "Bitte nicht als root und nicht mit sudo starten, sondern einfach: bash setup-wsl.sh"
fi

case "$PWD" in
  /mnt/*) fehler "Das Repository liegt auf dem Windows-Laufwerk ($PWD). Bitte im Linux-Home klonen: cd ~ und dann git clone" ;;
  *) ;;
esac

if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  if [ "${VERSION_ID:-}" != "24.04" ]; then
    printf 'Hinweis: getestet ist Ubuntu 24.04, hier laeuft %s %s.\n' "${NAME:-?}" "${VERSION_ID:-?}"
  fi
fi

# Docker und die Lab-Container brauchen systemd
if [ "$(ps -p 1 -o comm= 2>/dev/null | tr -d ' ')" != "systemd" ]; then
  printf '[boot]\nsystemd=true\n' | sudo tee /etc/wsl.conf >/dev/null
  printf '\nsystemd ist jetzt aktiviert, aber Ubuntu muss einmal neu starten.\n'
  printf 'Bitte in PowerShell ausfuehren:  wsl --shutdown\n'
  printf 'Danach Ubuntu neu oeffnen und dieses Skript noch einmal starten.\n'
  exit 1
fi
echo "systemd laeuft, Ordner ist $PWD"

schritt "Pakete installieren (Docker, Ansible, Hilfswerkzeuge)"
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
sudo -v
sudo apt-get update -qq
sudo apt-get install -y -qq \
  docker.io ansible python3 git curl wget gnupg lsb-release ca-certificates openssh-client

schritt "Terraform installieren"
if command -v terraform >/dev/null 2>&1; then
  echo "Terraform ist schon da: $(terraform version | head -n 1)"
else
  wget -qO- https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq terraform
  echo "Installiert: $(terraform version | head -n 1)"
fi

schritt "Docker starten und Benutzer freischalten"
sudo systemctl enable --now docker
if id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  echo "$USER ist schon in der Gruppe docker"
else
  sudo usermod -aG docker "$USER"
  echo "$USER wurde zur Gruppe docker hinzugefuegt (gilt in neuen Fenstern)"
fi

schritt "Ansible-Collection community.postgresql"
if ansible-galaxy collection list community.postgresql 2>/dev/null | grep -q community.postgresql; then
  echo "community.postgresql ist schon da"
else
  ansible-galaxy collection install community.postgresql
fi

schritt "Alles pruefen (lab00-check)"
# Die neue Gruppe gilt erst in neuen Fenstern, deshalb hier mit sg
RC=0
if docker info >/dev/null 2>&1; then
  bash lab00-check/check.sh || RC=$?
else
  sg docker -c "bash lab00-check/check.sh" || RC=$?
fi

if [ "$RC" -ne 0 ]; then
  printf '\n===== Es fehlt noch etwas, siehe [FEHLT] oben.\n'
  echo "Bitte die Ausgabe der Trainerin oder dem Trainer zeigen."
  exit 1
fi

printf '\n===== Fertig.\n'
echo "Ubuntu-Fenster bitte einmal schliessen und neu oeffnen, dann gilt die Gruppe docker."
echo "Test im neuen Fenster: docker ps    (leere Tabelle ist richtig, kein sudo noetig)"
