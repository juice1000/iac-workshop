# Miniprojekt: Anwendungsserver mit Datenbankserver

## Ziel

Alles zusammen, wie im Alltag: Terraform baut die Infrastruktur, Ansible konfiguriert sie. Ihr richtet einen Anwendungsserver ein, der mit einem entfernten PostgreSQL-Server spricht.

```
Browser/curl --> app1 (Python-Anwendung) --> db1 (PostgreSQL)
```

Am Ende antwortet die Anwendung mit `Hallo von tlbg-schulung-app1! DB OK (...), Besuche: N`. Die Datenbank ist von außen nicht erreichbar (Port 5432 nur im Anwendungsnetz).

## Schritt für Schritt (mit Checkpoints)

Geht die Schritte der Reihe nach. Nach jedem Schritt gibt es einen Test (Checkpoint). Geht erst weiter, wenn er grün ist. Grün heißt: nur `OK:`-Zeilen und im PLAY RECAP am Ende `ignored=0`. Eine Zeile `FEHLT:` nennt die Aufgabe, die ihr euch ansehen sollt.

Alle Ansible-Befehle laufen im Ordner `miniprojekt/ansible`.

### Schritt 1: Terraform

Der Terraform-Teil hat eigene Checkpoints, getrennt von Ansible: `bash pruefen.sh <name>` im Ordner `terraform`. Die ausführliche Anleitung (Aufruf, Ausgabe lesen, häufige Meldungen) steht in `terraform/README.md`. Erst wenn Terraform steht (Checkpoint 5), geht es mit Ansible weiter.

Arbeitet in dieser Reihenfolge. Die `TODO` mit Mustern stehen in den Dateien.

| # | Was ihr schreibt | Checkpoint | Grün heißt |
| --- | --- | --- | --- |
| 1 | `versions.tf` (terraform-Block, drei Provider, Docker-Provider) | `bash pruefen.sh init` | `terraform init` läuft, drei Provider geladen |
| 2 | `variables.tf` (`umgebung`, `netz`, `app_port`) | `bash pruefen.sh variablen` | Namen, Typen und Standardwerte stimmen |
| 3 | `main.tf`: Schlüssel (`local_sensitive_file`), Pfad zum Dockerfile, `ipam_config`, Modulaufruf, Inventory-Werte; `outputs.tf` (`app_url`, `ssh`, `db_ip`) | `bash pruefen.sh validate` | `terraform validate` ohne Fehler, alle Ressourcen und Ausgaben vorhanden, `terraform fmt` stimmt |
| 4 | `main.tf`: Eintrag `db1` in den `locals` | `bash pruefen.sh plan` | IP 172.30.0.21, SSH-Port 2202, keine veröffentlichten Ports, `terraform plan` läuft durch (bei leerem Zustand `Plan: 7 to add`) |
| 5 | `terraform apply` | `bash pruefen.sh apply` | Ausgaben, Schlüssel mit Rechten 0600, Inventory, zwei laufende Container, Subnetz, `db1` ohne Port 5432 |

```bash
cd miniprojekt/terraform
terraform init
bash pruefen.sh init
# ... Dateien schreiben, nach jedem Schritt den passenden Checkpoint ...
terraform apply
bash pruefen.sh apply             # grün? dann weiter mit Ansible
cd ../ansible
ansible-playbook pruefen.yml --tags verbindung     # Ansible-Checkpoint 1: beide Server erreichbar
```

`bash pruefen.sh` ohne Namen führt alle fünf Checkpoints nacheinander aus. Jede Zeile meldet `OK:` oder `FEHLT:` mit einem Hinweis, welche Stelle ihr euch ansehen sollt. Am Ende steht, wie viele Prüfungen fehlgeschlagen sind.

### Schritt 2: `site.yml`

Schreibt in `ansible/site.yml` die ersten beiden Plays (Datenbank, Anwendung) und den Smoke-Test.

```bash
ansible-playbook site.yml --syntax-check           # Checkpoint 2: keine Fehlermeldung
ansible-playbook site.yml --list-hosts             # Play 1 listet db1, Play 2 listet app1
```

### Schritt 3: Rolle `postgresql`

Ergänzt die `TODO` in `ansible/roles/postgresql/tasks/main.yml` und schreibt den Handler in `handlers/main.yml`.

```bash
ansible-playbook site.yml --limit db               # richtet nur den Datenbankserver ein
ansible-playbook pruefen.yml --tags db             # Checkpoint 3: sechs Zeilen OK
ansible-playbook pruefen.yml --tags zugriff        # Checkpoint 4: das Netz zwischen app1 und db1 steht
```

Im Checkpoint 4 meldet die Anmeldung mit Python noch `UEBERSPRUNGEN`. Das ist richtig, der Treiber kommt erst im nächsten Schritt.

### Schritt 4: Rolle `app`

Ergänzt die `TODO` in `ansible/roles/app/tasks/main.yml` und schreibt den Handler in `handlers/main.yml`. Die Vorlagen sind fertig.

```bash
ansible-playbook site.yml --limit app              # richtet nur den Anwendungsserver ein
ansible-playbook pruefen.yml --tags app            # Checkpoint 5: Treiber, Dienst, /health, "DB OK"
```

### Schritt 5: Alles zusammen und Neuaufbau

```bash
ansible-playbook site.yml                          # alles in einem Lauf
ansible-playbook site.yml                          # zweiter Lauf: changed=0
ansible-playbook pruefen.yml                       # Checkpoint 6: alle Prüfungen auf einmal
curl http://127.0.0.1:8080/                        # Antwort mit "DB OK"
curl http://127.0.0.1:8080/health                  # ok
```

Zum Schluss `terraform destroy` und alles von vorn, siehe unten (Aufräumen).

Bleibt ein Checkpoint rot: `FEHLT`-Hinweis lesen, die Aufgabe ansehen, mit `ansible-doc <modulname>` die Parameter nachschlagen, Schritt wiederholen. Weitere Hilfen (`--check --diff`, `--start-at-task`, `-vvv`) stehen in `ansible/README.md`.

Hilfe zu einem Modul: `ansible-doc <modulname>`.

Was der Ansible-Teil macht und warum (Datenbank öffnen, `lineinfile`, `pg_hba.conf`, woher die Variablen kommen): `miniprojekt/ansible/README.md`.

## Was Ansible bewirkt hat: der Ordner `out/`

Am Ende von `site.yml` holt Ansible Ergebnisse von den Servern in `miniprojekt/ansible/out/` (nicht im Git):

| Datei | Zeigt |
| --- | --- |
| `out/tlbg-schulung-db1/etc/postgresql/16/main/pg_hba.conf` | die Zugriffsregel der Datenbank (nur `app_netz`, nur `db_user`) |
| `out/tlbg-schulung-app1/etc/systemd/system/tlbg-app.service` | die Dienstdatei der Anwendung |
| `out/<server>/ports.txt` | welche Ports lauschen: 5432 auf `db1`, 8080 auf `app1` |
| `out/antwort.txt` | die Antwort der Anwendung ("DB OK") |

Schaut sie euch nach dem Lauf an, z. B. `cat out/*/ports.txt`.

## Aufräumen

```bash
cd miniprojekt/terraform
terraform destroy
```
