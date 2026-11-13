#!/usr/bin/env bash
# Erste Schritte mit Ansible auf der Kommandozeile.
# Am besten tippt ihr die Befehle selbst. Dieses Skript geht sie der Reihe nach durch.
# Pro Schritt: erst eine Erklaerung, was gleich passiert, dann der Befehl. Ausgefuehrt wird er erst,
# wenn ihr Enter drueckt. Danach seht ihr die Ausgabe.
# Aufruf im Ordner erste-schritte/ansible: bash rundgang.sh
set -uo pipefail

cd "$(dirname "$0")" || exit 1
# Kein Pager (less): ansible-doc und ansible-config wuerden im Terminal sonst auf eine Taste warten
export PAGER=cat ANSIBLE_PAGER=cat
NR=0
FEHLER=0

# schritt "Titel" "Erklaerung" "Befehl"
# Zeigt Titel, Erklaerung und Befehl, wartet auf Enter (nur im Terminal), fuehrt den Befehl dann aus.
# Fehlgeschlagene Schritte werden gezaehlt, der Rundgang laeuft trotzdem weiter.
schritt() {
  local titel="$1" erklaerung="$2" befehl="$3"
  NR=$((NR + 1))
  printf '\n===== Schritt %s: %s\n' "$NR" "$titel"
  printf 'Was jetzt kommt:\n'
  printf '%s\n' "$erklaerung" | fold -s -w 96 | sed 's/ *$//; s/^/  /'
  printf 'Befehl:\n  $ %s\n' "$befehl"
  if [ -t 0 ]; then
    read -r -p "--- Enter zum Ausfuehren " _
  fi
  printf -- '--- Ausgabe:\n'
  if ! bash -c "$befehl"; then
    printf '!!! Schritt %s ist fehlgeschlagen\n' "$NR"
    FEHLER=$((FEHLER + 1))
  fi
}

rm -rf out

schritt "Version, Python und gueltige ansible.cfg" \
  "Zeigt, welche Version von Ansible laeuft, welches Python dahintersteckt und welche Konfigurationsdatei gilt. Achtet auf die Zeile 'config file': Das ist die ansible.cfg aus diesem Ordner." \
  "ansible --version"

schritt "Was in unserer ansible.cfg vom Standard abweicht" \
  "Listet nur die Einstellungen, die von den Standardwerten abweichen. Das ist alles, was unsere ansible.cfg festlegt, zum Beispiel das Inventory und das Ausgabeformat." \
  "ansible-config dump --only-changed"

schritt "Was im Inventory steht" \
  "Zeigt das Inventory als Baum: die Gruppen und die Server darin. Hier gibt es nur die Gruppe lokal mit localhost. In Lab 3 seht ihr an dieser Stelle die Gruppe web mit server1 und server2." \
  "ansible-inventory --graph"

schritt "Ping: Verbindung und Python pruefen (kein ICMP)" \
  "Der Ping von Ansible ist kein Netzwerk-Ping. Ansible verbindet sich mit dem Server, startet dort Python und bekommt 'pong' zurueck. So pruefen wir Verbindung, Anmeldung und Python auf einmal. Mit -m waehlt man das Modul. Erwartet: SUCCESS und pong." \
  "ansible localhost -m ansible.builtin.ping"

schritt "Fakten ueber den Rechner, gefiltert" \
  "Ansible sammelt vor jedem Playbook Fakten ueber den Server: Betriebssystem, Speicher, Netzwerk und mehr. Das Modul setup zeigt sie. Mit -a gibt man dem Modul Argumente, hier einen Filter auf ansible_distribution*. Diese Fakten nutzt hallo.yml spaeter." \
  "ansible localhost -m ansible.builtin.setup -a 'filter=ansible_distribution*'"

schritt "Eine Nachricht ausgeben" \
  "Das Modul debug gibt nur einen Text aus und aendert nichts. Es zeigt das Muster: ansible <Gruppe> -m <Modul> -a '<Argumente>'." \
  "ansible localhost -m ansible.builtin.debug -a 'msg=\"Hallo Ansible\"'"

schritt "Einen Befehl ausfuehren: meldet immer CHANGED" \
  "Das Modul command fuehrt einen Befehl aus. Ansible kann nicht wissen, ob der Befehl etwas veraendert hat, und meldet deshalb immer CHANGED (gelb). Merkt euch das: Fuer fast alles gibt es ein Modul, das den Soll-Zustand kennt und nur aendert, was abweicht." \
  "ansible localhost -m ansible.builtin.command -a 'uname -a'"

schritt "Ordner anlegen: beim ersten Mal CHANGED" \
  "Das Modul file mit state=directory beschreibt einen Soll-Zustand: Der Ordner out muss existieren. Er fehlt noch, also legt Ansible ihn an und meldet CHANGED." \
  "ansible localhost -m ansible.builtin.file -a \"path=\$PWD/out state=directory\""

schritt "Derselbe Befehl noch einmal: jetzt SUCCESS, nichts zu tun" \
  "Genau derselbe Befehl nochmal. Der Ordner existiert, der Soll-Zustand ist schon erreicht. Ansible tut nichts und meldet SUCCESS statt CHANGED. Das nennt man Idempotenz und ist der Unterschied zu einem Shell-Skript." \
  "ansible localhost -m ansible.builtin.file -a \"path=\$PWD/out state=directory\""

schritt "Datei mit Inhalt schreiben" \
  "Das Modul copy schreibt einen Text in eine Datei. Die Datei gibt es noch nicht, also CHANGED." \
  "ansible localhost -m ansible.builtin.copy -a \"content='Hallo von Ansible' dest=\$PWD/out/hallo.txt\""

schritt "Probelauf mit anderem Inhalt: zeigt den Unterschied, aendert nichts" \
  "--check ist ein Probelauf: Ansible sagt, was es aendern wuerde, aendert aber nichts. --diff zeigt den Unterschied Zeile fuer Zeile (rot entfernt, gruen neu). Die Datei hallo.txt behaelt danach den alten Inhalt." \
  "ansible localhost -m ansible.builtin.copy -a \"content='Moin von Ansible' dest=\$PWD/out/hallo.txt\" --check --diff"

schritt "Welche Module bringt ansible.builtin mit?" \
  "Listet alle Module der mitgelieferten Sammlung ansible.builtin. Ein Modul ist ein fertiger Baustein fuer eine Aufgabe." \
  "ansible-doc -l ansible.builtin"

schritt "Kurzform eines Moduls: alle Parameter auf einen Blick" \
  "Zeigt zu einem Modul alle Parameter in Kurzform, als Vorlage fuer ein Playbook. So findet ihr beim Schreiben heraus, wie ein Parameter heisst. Die ausfuehrliche Hilfe gibt es ohne -s." \
  "ansible-doc -s ansible.builtin.copy"

schritt "Ist die Collection fuer das Miniprojekt da?" \
  "Eine Collection ist ein Paket mit weiteren Modulen. Das Miniprojekt braucht community.postgresql fuer die Datenbank. Hier seht ihr, ob sie installiert ist." \
  "ansible-galaxy collection list community.postgresql"

schritt "Wie viele Module stecken z. B. in community.general?" \
  "Zaehlt die Module einer grossen Collection, damit ihr ein Gefuehl dafuer bekommt, wie viele fertige Bausteine es gibt." \
  "ansible-doc -l community.general | wc -l"

schritt "Ein Playbook: erster Lauf" \
  "Jetzt ein Playbook statt einzelner Befehle. hallo.yml legt den Ordner out an, schreibt rechner.txt mit Fakten und gibt eine Nachricht aus. Jede Zeile ist in der Datei erklaert. Erster Lauf: changed bei den ersten beiden Aufgaben. Achtet am Ende auf den PLAY RECAP." \
  "ansible-playbook hallo.yml"

schritt "Zweiter Lauf: changed=0" \
  "Dasselbe Playbook nochmal. Alles ist schon im Soll-Zustand, deshalb steht im PLAY RECAP changed=0. Das ist die Idempotenz, auf die wir uns in allen Labs verlassen." \
  "ansible-playbook hallo.yml"

schritt "Probelauf mit anderer Variable" \
  "Wie vorhin ein Probelauf, diesmal fuer das ganze Playbook. Mit -e wird die Variable begruessung von der Kommandozeile ueberschrieben (-e gewinnt gegen vars im Playbook). Ihr seht im Diff, dass sich rechner.txt aendern wuerde, ohne dass etwas geschrieben wird." \
  "ansible-playbook hallo.yml --check --diff -e begruessung=Moin"

schritt "Das Ergebnis" \
  "Zeigt die Datei, die das Playbook geschrieben hat. Sie enthaelt noch 'Hallo', weil der Probelauf davor nichts geaendert hat." \
  "cat out/rechner.txt"

printf '\nRundgang fertig, %s Fehler.\n' "$FEHLER"
exit "$FEHLER"
