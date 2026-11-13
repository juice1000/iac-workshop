# Miniprojekt: der Ansible-Teil

Dieser Ordner macht aus den leeren Servern, die Terraform gebaut hat, eine laufende Anwendung. Terraform hat zwei Container mit Ubuntu geliefert (`app1` und `db1`) und das Inventory geschrieben. Jetzt installiert und konfiguriert Ansible, was darauf laufen soll.

## Was entsteht

```
Browser/curl --> app1 (Python-Anwendung, Port 8080) --> db1 (PostgreSQL, Port 5432)
                 172.30.0.11                             172.30.0.21
```

Die Anwendung zählt bei jedem Aufruf einen Besuch in einer Tabelle der Datenbank. Antwortet sie mit `DB OK`, funktioniert die ganze Kette: Netz, Datenbank, Zugangsdaten, Anwendung.

Der Aufbau ist typisch für den Alltag: Anwendung und Datenbank liegen auf getrennten Servern, und die Datenbank soll nur die Anwendung erreichen, nicht das ganze Netz.

## Checkpoints: nach jedem Schritt prüfen

Den Schritt-für-Schritt-Ablauf mit allen Befehlen findet ihr in `../README.md`. Ihr löst alles selbst. Damit ihr nicht bis zum Schluss im Dunkeln tappt, gibt es nach jedem Schritt einen Test. Geht erst weiter, wenn der Checkpoint grün ist. Alle Befehle im Ordner `miniprojekt/ansible`.

| # | Nach welchem Schritt | Befehl | Grün heißt |
| --- | --- | --- | --- |
| 1 | Terraform angewendet | `terraform output` (im Ordner `terraform`), dann `ansible-playbook pruefen.yml --tags verbindung` | beide Server erreichbar, `ansible-inventory --graph` zeigt die Gruppen `app` und `db` |
| 2 | `site.yml`: Plays geschrieben | `ansible-playbook site.yml --syntax-check` und `ansible-playbook site.yml --list-hosts` | keine Fehlermeldung; Play 1 listet `tlbg-schulung-db1`, Play 2 listet `tlbg-schulung-app1` |
| 3 | Rolle `postgresql` + Handler fertig | `ansible-playbook site.yml --limit db`, dann `ansible-playbook pruefen.yml --tags db` | sechs Zeilen `OK:` (Dienst, Port, `pg_hba.conf`, Benutzer, Datenbank, Anmeldung mit Passwort), im PLAY RECAP `ignored=0` |
| 4 | Datenbank von der App-Seite aus | `ansible-playbook pruefen.yml --tags zugriff` | `OK:` beim Datenbankport: das Netz zwischen `app1` und `db1` steht. Die Anmeldung mit Python meldet `UEBERSPRUNGEN`, bis die Rolle `app` den Treiber installiert hat |
| 5 | Rolle `app` + Handler fertig | `ansible-playbook site.yml --limit app`, dann `ansible-playbook pruefen.yml --tags app` | `OK: psycopg2`, `OK: tlbg-app laeuft`, `OK: /health ...`, `DB OK`, `ignored=0` |
| 6 | Alles zusammen | `ansible-playbook site.yml` zweimal, dann `curl http://127.0.0.1:8080/` | zweiter Lauf `changed=0`, Antwort enthält `DB OK` |

Wie ihr die Ausgabe von `pruefen.yml` lest: Jede Prüfung meldet `OK: ...` oder `FEHLT: ... Hinweis: ...`. Der Hinweis nennt die Aufgabe, die ihr euch ansehen sollt. Im PLAY RECAP bedeutet `ignored=0`: alles in Ordnung, jede Zahl darüber ist eine fehlgeschlagene Prüfung. `ansible-playbook pruefen.yml` ohne `--tags` führt alle Checkpoints aus.

Weitere Werkzeuge, wenn etwas nicht klappt:

- `ansible-playbook site.yml --check --diff`: zeigt, was sich ändern würde, ohne etwas zu ändern
- `ansible-playbook site.yml --limit db --start-at-task "Datenbank anlegen"`: macht bei einer Aufgabe weiter, statt von vorn
- `ansible-playbook site.yml -vvv`: zeigt jedes Detail, auch die genauen Befehle
- `ansible-playbook site.yml --list-tasks`: zeigt die Aufgaben in der Reihenfolge, in der sie laufen würden
- Auf dem Server nachsehen: `ssh -i ../terraform/.ssh/id_lab -p 2202 root@127.0.0.1` (db1) oder Port `2201` (app1), dort `journalctl -u tlbg-app`

## Ablauf von `site.yml`

| Play | Server | Was passiert |
| --- | --- | --- |
| Datenbankserver einrichten | Gruppe `db` | Rolle `postgresql` |
| Anwendungsserver einrichten | Gruppe `app` | Rolle `app` |
| Smoke-Test | Gruppe `app` | Anwendung abrufen und prüfen, ob "DB OK" in der Antwort steht |
| Ergebnisse in out/ sammeln | alle | Dateien und Auskünfte von den Servern nach `out/` holen |

Die Datenbank kommt zuerst, weil die Anwendung beim Start sofort eine Verbindung braucht.

## Rolle `postgresql`: warum diese Schritte?

Nach `apt install postgresql` läuft die Datenbank, ist aber für unseren Zweck unbrauchbar. Drei Dinge fehlen, und jedes hat eine eigene Aufgabe:

| Problem nach der Installation | Aufgabe | Modul |
| --- | --- | --- |
| PostgreSQL lauscht nur auf `127.0.0.1`. Programme auf anderen Servern erreichen es nicht. | `listen_addresses = '*'` in `postgresql.conf` eintragen | `lineinfile` |
| Die Zugriffsregeln (`pg_hba.conf`) kennen keine Verbindung von außen. | Eine Zeile hinzufügen: Benutzer `db_user` darf auf `db_name` aus dem Netz `app_netz` mit Passwort | `postgresql_pg_hba` |
| Es gibt weder Benutzer noch Datenbank für die Anwendung. | Beides anlegen | `postgresql_user`, `postgresql_db` |

### Wozu das `lineinfile`?

`postgresql.conf` ist eine lange Konfigurationsdatei mit hunderten Zeilen, die dem Paket gehört. Wir wollen genau eine Einstellung ändern und den Rest nicht anfassen. Dafür ist `lineinfile` da:

- `regexp: "^#?listen_addresses"` findet die Zeile, die mit `listen_addresses` beginnt. Das `#?` heißt: mit oder ohne Kommentarzeichen davor. In der Standarddatei steht die Zeile auskommentiert (`#listen_addresses = 'localhost'`), und genau die wird getroffen.
- `line: "listen_addresses = '*'"` ersetzt sie. `'*'` heißt: auf allen Netzwerkschnittstellen lauschen, nicht nur auf localhost.
- Ist die Zeile schon richtig, ändert sich nichts. Das macht den zweiten Lauf `changed=0`.
- Mit `template` müssten wir die ganze Datei besitzen und mitpflegen. Für eine Einstellung wäre das übertrieben.

Wichtig: `'*'` öffnet nur die Tür auf Netzwerkebene. Wer hindurch darf, regelt `pg_hba.conf`. Deshalb braucht es beides.

### `pg_hba.conf`: wer darf von wo rein?

Die Datei wird von oben nach unten gelesen, die erste passende Zeile gilt. Unsere Zeile lautet im Ergebnis:

```
host  tlbg_app  tlbg_app  172.30.0.0/24  scram-sha-256
```

Das heißt: Verbindung über Netzwerk, zur Datenbank `tlbg_app`, als Benutzer `tlbg_app`, aus dem Netz `172.30.0.0/24`, geprüft per Passwort (`scram-sha-256`). Alles andere bleibt abgewiesen. Nach dem Lauf könnt ihr die echte Datei ansehen: `out/tlbg-schulung-db1/etc/postgresql/16/main/pg_hba.conf`.

### Benutzer und Datenbank: `become_user: postgres`

Nur der Datenbank-Administrator `postgres` darf Benutzer und Datenbanken anlegen. Die Aufgaben laufen deshalb mit `become_user: postgres` (wie `sudo -u postgres`). `no_log: true` verhindert, dass das Passwort im Log von Ansible erscheint.

## Rolle `app`: warum diese Schritte?

| Schritt | Wozu |
| --- | --- |
| `python3-psycopg2` installieren | Der Treiber, mit dem Python mit PostgreSQL spricht |
| Systembenutzer `tlbg-app` anlegen | Die Anwendung läuft mit minimalen Rechten, nicht als root |
| Verzeichnis `/opt/tlbg-app` und `app.py` | Die Anwendung selbst, aus der Vorlage `app.py.j2` |
| `/etc/tlbg-app.env` (Rechte `0640`) | Zugangsdaten zur Datenbank. Nur root und die Gruppe der Anwendung dürfen lesen |
| `tlbg-app.service` | Dienstdatei für systemd. Sie startet `app.py` und liest `tlbg-app.env` ein |
| Dienst starten und aktivieren | Läuft jetzt und nach jedem Neustart des Servers |

Ändert sich eine der drei Dateien, startet der Handler `Anwendung neu starten` die Anwendung neu (`notify`). Ohne Änderung bleibt sie unberührt.

## Woher kommen die Werte?

| Variable | Definiert in | Benutzt in |
| --- | --- | --- |
| `db_name`, `db_user`, `db_password` | `group_vars/all.yml` (gilt für alle Server) | beide Rollen |
| `db_host`, `app_netz`, `app_port` | `inventory.ini` unter `[all:vars]`, von Terraform erzeugt | `app` (Adresse der Datenbank), `postgresql` (erlaubtes Netz) |
| `postgresql_version`, `postgresql_conf_dir`, `postgresql_erlaubtes_netz` | `roles/postgresql/defaults/main.yml` | Rolle `postgresql` |
| `app_user`, `app_dir` | `roles/app/defaults/main.yml` | Rolle `app` |

Terraform und Ansible hängen so zusammen: Terraform kennt die IP der Datenbank (`172.30.0.21`) und schreibt sie als `db_host` ins Inventory. Ansible reicht sie über `app.env.j2` an die Anwendung weiter. Ändert ihr die IP in Terraform, passt sich alles an.

Das Passwort steht in `group_vars/all.yml` im Klartext, nur für die Übung. In echten Projekten kommt es in Ansible Vault (Zusatzaufgabe).

## Ergebnis prüfen

```bash
ansible-playbook site.yml           # Smoke-Test am Ende: "DB OK"
curl http://127.0.0.1:8080/         # Hallo von tlbg-schulung-app1! DB OK (172.30.0.21), Besuche: N
curl http://127.0.0.1:8080/health   # ok
ansible-playbook site.yml           # zweiter Lauf: changed=0
cat out/*/ports.txt                 # 5432 lauscht auf db1, 8080 auf app1
```

Der Port 5432 ist von eurem Rechner aus nicht erreichbar, weil Terraform ihn nicht veröffentlicht. Nur `app1` erreicht die Datenbank über das Docker-Netz.

## Häufige Fragen

**Warum wird `python3-psycopg2` auch auf `db1` installiert?** Die Ansible-Module `postgresql_user` und `postgresql_db` laufen auf dem Server und sprechen dort mit der Datenbank. Dafür brauchen sie den Treiber.

**Warum steht die Warnung `remote_tmp ... did not exist` beim ersten Lauf?** Beim Wechsel zum Benutzer `postgres` legt Ansible ein temporäres Verzeichnis an, das noch nicht existiert. Sie ist harmlos und kommt nur beim ersten Lauf.

**Was, wenn die Anwendung "DB FEHLER" meldet?** Das passiert, wenn die Verbindung scheitert. Prüfe in dieser Reihenfolge: lauscht die Datenbank (`out/tlbg-schulung-db1/ports.txt`), steht die Zeile in `pg_hba.conf`, stimmen `db_host`, Benutzer und Passwort in `/etc/tlbg-app.env`. Auf dem Server hilft `journalctl -u tlbg-app`.

**Wo finde ich Hilfe zu einem Modul?** `ansible-doc ansible.builtin.lineinfile` oder `ansible-doc community.postgresql.postgresql_pg_hba`. Weitere Befehle stehen in `erste-schritte/ansible/README.md`.
