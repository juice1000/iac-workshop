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

Ergänzt die `TODO` in `terraform/`: `versions.tf`, `variables.tf` und `outputs.tf` schreibt ihr selbst, in `main.tf` fehlen der Schlüssel (`local_sensitive_file`), der Pfad zum Dockerfile, Server `db1`, das Subnetz, die Eingaben des Moduls und die Werte für das Inventory. Zu jeder Lücke steht ein Muster dabei.

```bash
cd miniprojekt/terraform
terraform init && terraform apply
cd ../ansible
ansible-playbook pruefen.yml --tags verbindung     # Checkpoint 1: beide Server erreichbar
```

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
