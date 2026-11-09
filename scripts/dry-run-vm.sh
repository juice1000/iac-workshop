#!/usr/bin/env bash
# Probelauf fuer Variante B (Linux-VMs statt Docker).
# Fuehrt nur die Ansible-Labs gegen vorhandene Server aus. Terraform-Labs 1, 2, 4 laufen unveraendert
# ueber scripts/dry-run.sh. Die Server brauchen SSH-Zugang und sudo.
#
# Aufruf:
#   INVENTORY=/pfad/inventory.ini bash scripts/dry-run-vm.sh
#   INVENTORY=... MINI_INVENTORY=/pfad/mini.ini bash scripts/dry-run-vm.sh   (mit Miniprojekt)
#
# INVENTORY      Inventory mit Gruppe [web] (Lab 3 und Lab 5)
# MINI_INVENTORY Inventory mit Gruppen [app] und [db] sowie den Variablen db_host, app_netz, app_port
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ANSIBLE_FORCE_COLOR=0

fehler() {
  printf 'FEHLER: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '\n===== %s\n' "$*"
}

[ -n "${INVENTORY:-}" ] || fehler "INVENTORY ist nicht gesetzt"
[ -f "$INVENTORY" ] || fehler "Inventory nicht gefunden: $INVENTORY"
INVENTORY="$(cd "$(dirname "$INVENTORY")" && pwd)/$(basename "$INVENTORY")"
if [ -n "${MINI_INVENTORY:-}" ]; then
  [ -f "$MINI_INVENTORY" ] || fehler "Inventory nicht gefunden: $MINI_INVENTORY"
  MINI_INVENTORY="$(cd "$(dirname "$MINI_INVENTORY")" && pwd)/$(basename "$MINI_INVENTORY")"
fi

idempotent() {
  local ausgabe
  ausgabe="$(ansible-playbook "$@")"
  printf '%s\n' "$ausgabe" | tail -n 6
  if printf '%s\n' "$ausgabe" | grep -Eq 'changed=[1-9]'; then
    fehler "Playbook ist nicht idempotent: $*"
  fi
}

log "Erreichbarkeit"
ansible -i "$INVENTORY" all -m ansible.builtin.ping
ansible -i "$INVENTORY" all -b -m ansible.builtin.command -a "id -u" | grep -q '^0$' || fehler "sudo (become) funktioniert nicht"

log "Lab 3: Ansible-Grundlagen"
cd "$ROOT/lab03-ansible-grundlagen"
ansible -i "$INVENTORY" web -a "uptime"
ansible-playbook -i "$INVENTORY" playbook.yml | tail -n 6
idempotent -i "$INVENTORY" playbook.yml
ansible-playbook -i "$INVENTORY" playbook.yml --check --diff -e web_port=8081 | tail -n 6
ansible-playbook -i "$INVENTORY" playbook.yml -e web_port=8081 | tail -n 6
ansible -i "$INVENTORY" web -m ansible.builtin.uri -a "url=http://localhost:8081 return_content=true" >/dev/null
echo "Lab 3 OK"

log "Lab 5: Rolle"
cd "$ROOT/lab05-ansible-rolle"
ansible-playbook -i "$INVENTORY" site.yml | tail -n 6
idempotent -i "$INVENTORY" site.yml
echo "Lab 5 OK"

if [ -n "${MINI_INVENTORY:-}" ]; then
  log "Miniprojekt: Ansible"
  cd "$ROOT/miniprojekt/ansible"
  ansible-playbook -i "$MINI_INVENTORY" site.yml | tail -n 6
  idempotent -i "$MINI_INVENTORY" site.yml
  echo "Miniprojekt OK"
else
  echo "MINI_INVENTORY nicht gesetzt: Miniprojekt uebersprungen"
fi

log "Alles erfolgreich"
