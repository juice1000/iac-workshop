#!/usr/bin/env bash
# Erste Schritte mit Ansible auf der Kommandozeile.
# Am besten tippt ihr die Befehle selbst. Dieses Skript zeigt sie der Reihe nach,
# fuehrt sie aus und wartet nach jedem Schritt auf Enter.
# Aufruf im Ordner erste-schritte/ansible: bash rundgang.sh
set -uo pipefail

cd "$(dirname "$0")" || exit 1
NR=0
FEHLER=0

# Schritt anzeigen, Befehl ausfuehren, auf Enter warten (nur im Terminal).
# Fehlgeschlagene Schritte werden gezaehlt, der Rundgang laeuft trotzdem weiter.
schritt() {
  local text="$1"
  shift
  NR=$((NR + 1))
  printf '\n===== Schritt %s: %s\n$ %s\n' "$NR" "$text" "$*"
  if ! bash -c "$*"; then
    printf '!!! Schritt %s ist fehlgeschlagen\n' "$NR"
    FEHLER=$((FEHLER + 1))
  fi
  if [ -t 0 ]; then
    read -r -p "--- Enter fuer weiter " _
  fi
}

rm -rf out

schritt "Version, Python und gueltige ansible.cfg" \
  "ansible --version"
schritt "Was in unserer ansible.cfg vom Standard abweicht" \
  "ansible-config dump --only-changed"
schritt "Was im Inventory steht" \
  "ansible-inventory --graph"

schritt "Ping: Verbindung und Python pruefen (kein ICMP)" \
  "ansible localhost -m ansible.builtin.ping"
schritt "Fakten ueber den Rechner, gefiltert" \
  "ansible localhost -m ansible.builtin.setup -a 'filter=ansible_distribution*'"
schritt "Eine Nachricht ausgeben" \
  "ansible localhost -m ansible.builtin.debug -a 'msg=\"Hallo Ansible\"'"
schritt "Einen Befehl ausfuehren: meldet immer CHANGED" \
  "ansible localhost -m ansible.builtin.command -a 'uname -a'"

schritt "Ordner anlegen: beim ersten Mal CHANGED" \
  "ansible localhost -m ansible.builtin.file -a \"path=\$PWD/out state=directory\""
schritt "Derselbe Befehl noch einmal: jetzt SUCCESS, nichts zu tun" \
  "ansible localhost -m ansible.builtin.file -a \"path=\$PWD/out state=directory\""
schritt "Datei mit Inhalt schreiben" \
  "ansible localhost -m ansible.builtin.copy -a \"content='Hallo von Ansible' dest=\$PWD/out/hallo.txt\""
schritt "Probelauf mit anderem Inhalt: zeigt den Unterschied, aendert nichts" \
  "ansible localhost -m ansible.builtin.copy -a \"content='Moin von Ansible' dest=\$PWD/out/hallo.txt\" --check --diff"

schritt "Welche Module bringt ansible.builtin mit?" \
  "ansible-doc -l ansible.builtin"
schritt "Kurzform eines Moduls: alle Parameter auf einen Blick" \
  "ansible-doc -s ansible.builtin.copy"
schritt "Ist die Collection fuer das Miniprojekt da?" \
  "ansible-galaxy collection list community.postgresql"
schritt "Wie viele Module stecken z. B. in community.general?" \
  "ansible-doc -l community.general | wc -l"

schritt "Ein Playbook: erster Lauf" \
  "ansible-playbook hallo.yml"
schritt "Zweiter Lauf: changed=0" \
  "ansible-playbook hallo.yml"
schritt "Probelauf mit anderer Variable" \
  "ansible-playbook hallo.yml --check --diff -e begruessung=Moin"
schritt "Das Ergebnis" \
  "cat out/rechner.txt"

printf '\nRundgang fertig, %s Fehler.\n' "$FEHLER"
exit "$FEHLER"
