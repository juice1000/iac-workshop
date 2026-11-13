# Erste Schritte mit Ansible: die wichtigsten Befehle

Diese Seite ist die Kurzreferenz für den Workshop. Alle Befehle laufen im Ordner des jeweiligen Labs, weil dort die `ansible.cfg` und das Inventory liegen. Die Beispiele hier gelten für diesen Ordner (`erste-schritte/ansible`, Gruppe `lokal`). In Lab 3 und im Miniprojekt heißen die Gruppen `web`, `app` und `db`, sonst bleibt alles gleich.

Den geführten Durchlauf aller Befehle startet `bash rundgang.sh`. Er erklärt jeden Schritt, bevor er ihn ausführt.

## Das Muster

```
ansible <Gruppe> -m <Modul> -a '<Argumente>'        # ein einzelnes Modul, ohne Playbook
ansible-playbook <datei.yml> [Optionen]             # ein Playbook ausführen
```

## Playbook ausführen und prüfen

| Befehl | Wozu |
| --- | --- |
| `ansible-playbook hallo.yml` | Playbook ausführen |
| `ansible-playbook hallo.yml --syntax-check` | nur die Syntax prüfen, es wird nichts ausgeführt |
| `ansible-playbook hallo.yml --check --diff` | **Probelauf**: zeigt, was sich ändern würde, und die Unterschiede in den Dateien. Es wird nichts geändert |
| `ansible-playbook hallo.yml -e begruessung=Moin` | Variable von der Kommandozeile setzen. `-e` gewinnt gegen `vars` im Playbook |
| `ansible-playbook hallo.yml --limit server1` | nur auf einem Server oder einer Gruppe aus dem Inventory ausführen |
| `ansible-playbook hallo.yml --list-hosts` | zeigt, auf welchen Servern das Playbook laufen würde |
| `ansible-playbook hallo.yml --list-tasks` | zeigt alle Aufgaben, ohne etwas auszuführen |
| `ansible-playbook hallo.yml --start-at-task "Ergebnis zeigen"` | beginnt bei einer bestimmten Aufgabe (Name in Anführungszeichen) |
| `ansible-playbook hallo.yml -v` | mehr Ausgabe, bis `-vvv` (bei Verbindungsproblemen auch den `ssh`-Aufruf) |

Die Reihenfolge im Alltag: erst `--syntax-check`, dann `--check --diff`, dann ausführen, dann ein zweites Mal ausführen.

## Die Ausgabe lesen

| Anzeige | Bedeutung |
| --- | --- |
| `ok` (grün) | Soll-Zustand war schon erreicht, nichts getan |
| `changed` (gelb) | Ansible hat etwas geändert |
| `failed` (rot) | Fehler. Die Meldung steht direkt darunter. Das Playbook bricht für diesen Server ab |
| `skipped` | Aufgabe übersprungen (zum Beispiel wegen `when`) |
| `unreachable` | Server nicht erreichbar (Inventory, Port, Schlüssel) |

Am Ende steht der `PLAY RECAP` mit Zahlen pro Server:

```
localhost : ok=4  changed=0  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

**Idempotenz-Test:** Läuft ein Playbook zum zweiten Mal, muss `changed=0` dastehen. Steht dort eine andere Zahl, ändert eine Aufgabe bei jedem Lauf etwas und beschreibt keinen Soll-Zustand.

## Einzelne Module ohne Playbook (Ad-hoc)

| Befehl | Wozu |
| --- | --- |
| `ansible lokal -m ansible.builtin.ping` | prüft Verbindung, Anmeldung und Python (kein Netzwerk-Ping) |
| `ansible lokal -m ansible.builtin.setup -a 'filter=ansible_distribution*'` | Fakten über den Server, hier gefiltert |
| `ansible lokal -m ansible.builtin.command -a 'uptime'` | Befehl ausführen. Meldet immer `changed` |
| `ansible lokal -m ansible.builtin.file -a 'path=/tmp/x state=directory'` | Soll-Zustand herstellen: Ordner muss existieren |
| `ansible web -b -m ansible.builtin.apt -a 'name=nginx state=present'` | `-b` (become) führt mit sudo aus, nötig für Pakete |

Mit `ansible all` statt der Gruppe läuft der Befehl auf jedem Server aus dem Inventory.

## Inventory ansehen

| Befehl | Wozu |
| --- | --- |
| `ansible-inventory --graph` | Gruppen und Server als Baum |
| `ansible-inventory --list` | alles als JSON, mit allen Variablen |
| `ansible-inventory --host server1` | die Variablen eines Servers (zum Beispiel `ansible_host` und `ansible_port`) |

Wenn ein Server nicht erreichbar ist, hilft meist erst `ansible-inventory --host <name>` (stimmen Adresse, Port und Schlüssel?) und dann `ansible <name> -m ansible.builtin.ping -vvv`.

## Module nachschlagen

| Befehl | Wozu |
| --- | --- |
| `ansible-doc -l ansible.builtin` | alle Module einer Sammlung auflisten |
| `ansible-doc ansible.builtin.copy` | ausführliche Hilfe zu einem Modul, mit Beispielen am Ende |
| `ansible-doc -s ansible.builtin.copy` | Kurzform: alle Parameter als Vorlage |
| `ansible-doc -l community.postgresql` | Module aus einer Collection (Miniprojekt) |

## Konfiguration, Collections, Stil

| Befehl | Wozu |
| --- | --- |
| `ansible --version` | Version, Python und welche `ansible.cfg` gilt |
| `ansible-config dump --only-changed` | Einstellungen, die von den Standardwerten abweichen |
| `ansible-galaxy collection list community.postgresql` | prüft, ob eine Collection installiert ist |
| `ansible-galaxy collection install -r requirements.yml` | installiert die Collections aus der Liste (Miniprojekt) |
| `ansible-lint` | prüft Playbooks und Rollen auf Stil und Fallstricke |

## Häufige Fehler

| Meldung | Meist die Ursache |
| --- | --- |
| `UNREACHABLE` / `Connection refused` | Server läuft nicht (`docker ps`), falscher Port im Inventory |
| `Permission denied (publickey)` | falscher Schlüssel im Inventory, `ansible_user` stimmt nicht |
| `Could not match supplied host pattern` | Gruppe im Playbook (`hosts:`) steht nicht im Inventory |
| `couldn't resolve module/action` | Modulname falsch geschrieben oder Collection fehlt |
| `changed` bei jedem Lauf | Aufgabe mit `command` oder `shell`: nicht idempotent, besser ein Modul nehmen |
