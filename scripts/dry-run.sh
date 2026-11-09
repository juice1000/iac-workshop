#!/usr/bin/env bash
# Probelauf aller Labs fuer den Trainer.
# Baut alles auf, prueft Ergebnisse und Idempotenz und raeumt am Ende wieder auf.
# Aufruf aus dem Repository-Ordner: bash scripts/dry-run.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export TF_IN_AUTOMATION=1
export ANSIBLE_FORCE_COLOR=0

log() {
  printf '\n===== %s\n' "$*"
}

fehler() {
  printf 'FEHLER: %s\n' "$*" >&2
  exit 1
}

tf() {
  terraform "$@" -input=false -no-color
}

# Playbook ausfuehren und Zusammenfassung zeigen
playbook() {
  ansible-playbook "$@" | tail -n 6
}

# Zweiter Lauf darf nichts aendern
idempotent() {
  local ausgabe
  ausgabe="$(ansible-playbook "$@")"
  printf '%s\n' "$ausgabe" | tail -n 6
  if printf '%s\n' "$ausgabe" | grep -Eq 'changed=[1-9]'; then
    fehler "Playbook ist nicht idempotent: $*"
  fi
}

# Warten, bis alle Server per SSH erreichbar sind
warte_auf_ssh() {
  local versuch
  for versuch in $(seq 1 30); do
    if ansible all -m ansible.builtin.ping >/dev/null 2>&1; then
      echo "Alle Server erreichbar (Versuch ${versuch})"
      return 0
    fi
    sleep 2
  done
  ansible all -m ansible.builtin.ping || true
  fehler "Server nicht per SSH erreichbar"
}

aufraeumen() {
  log "Aufraeumen"
  (cd "$ROOT/miniprojekt/terraform" && tf destroy -auto-approve >/dev/null 2>&1) || true
  (cd "$ROOT/umgebung" && tf destroy -auto-approve >/dev/null 2>&1) || true
  for d in lab01-terraform-grundlagen lab02-terraform-variablen lab04-terraform-module; do
    (cd "$ROOT/$d" && tf destroy -auto-approve >/dev/null 2>&1) || true
  done
}
trap aufraeumen EXIT

log "Lab 0: Werkzeuge"
bash "$ROOT/lab00-check/check.sh" || echo "Hinweis: nicht alle Checks gruen, Probelauf geht weiter"

log "Lab 1: Terraform-Grundlagen"
cd "$ROOT/lab01-terraform-grundlagen"
tf init >/dev/null
tf validate
tf apply -auto-approve >/dev/null
grep -q "Hallo Terraform" out/hallo.txt || fehler "out/hallo.txt fehlt"
tf plan -detailed-exitcode >/dev/null || fehler "Lab 1: zweiter Plan nicht leer"
tf destroy -auto-approve >/dev/null
echo "Lab 1 OK"

log "Lab 2: Variablen, for_each, Vorlage"
cd "$ROOT/lab02-terraform-variablen"
tf init >/dev/null
tf validate
tf apply -auto-approve >/dev/null
cat out/inventory.ini
grep -q '^\[app\]' out/inventory.ini || fehler "Gruppe [app] fehlt im Inventory"
grep -q '^app1 ansible_host=127.0.0.1 ansible_port=2201' out/inventory.ini || fehler "app1 fehlt im Inventory"
[ -n "$(terraform output -raw db_passwort)" ] || fehler "db_passwort leer"
if tf plan -var 'umgebung=dev' >/dev/null 2>&1; then fehler "Validierung greift nicht"; fi
tf destroy -auto-approve >/dev/null
echo "Lab 2 OK"

log "Lab 4: Module"
cd "$ROOT/lab04-terraform-module"
tf init >/dev/null
tf validate
tf apply -auto-approve >/dev/null
terraform state list | grep -q 'module.server_info\["app1"\].local_file.info' || fehler "Moduladresse fehlt"
tf destroy -auto-approve >/dev/null
echo "Lab 4 OK"

log "Umgebung fuer Lab 3 und Lab 5"
cd "$ROOT/umgebung"
tf init >/dev/null
tf validate
tf apply -auto-approve >/dev/null
cat "$ROOT/lab03-ansible-grundlagen/inventory.ini"

log "Lab 3: Ansible-Grundlagen"
cd "$ROOT/lab03-ansible-grundlagen"
warte_auf_ssh
ansible web -a "uptime"
playbook playbook.yml
idempotent playbook.yml
playbook playbook.yml --check --diff -e web_port=8081
playbook playbook.yml -e web_port=8081
ansible web -m ansible.builtin.uri -a "url=http://localhost:8081 return_content=true" >/dev/null
echo "Lab 3 OK"

log "Lab 5: Rolle"
cd "$ROOT/lab05-ansible-rolle"
playbook site.yml
idempotent site.yml
echo "Lab 5 OK"

log "Miniprojekt: Terraform"
cd "$ROOT/miniprojekt/terraform"
tf init >/dev/null
tf validate
tf apply -auto-approve >/dev/null
cat "$ROOT/miniprojekt/ansible/inventory.ini"

log "Miniprojekt: Ansible"
cd "$ROOT/miniprojekt/ansible"
warte_auf_ssh
playbook site.yml
idempotent site.yml
antwort="$(curl -fsS http://127.0.0.1:8080/)"
echo "$antwort"
case "$antwort" in
  *"DB OK"*) ;;
  *) fehler "Anwendung erreicht die Datenbank nicht" ;;
esac
if (exec 3<>/dev/tcp/127.0.0.1/5432) 2>/dev/null; then
  fehler "DB-Port 5432 ist vom Rechner aus erreichbar"
fi
echo "Miniprojekt OK"

log "Alles erfolgreich"
