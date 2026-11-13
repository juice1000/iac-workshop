# Miniprojekt: Anwendungsserver mit Datenbankserver

## Ziel

Alles zusammen, wie im Alltag: Terraform baut die Infrastruktur, Ansible konfiguriert sie. Ihr richtet einen Anwendungsserver ein, der mit einem entfernten PostgreSQL-Server spricht.

```
Browser/curl --> app1 (Python-Anwendung) --> db1 (PostgreSQL)
```

Am Ende antwortet die Anwendung mit `Hallo von tlbg-schulung-app1! DB OK (...), Besuche: N`. Die Datenbank ist von außen nicht erreichbar (Port 5432 nur im Anwendungsnetz).

## Phasen

1. **Terraform**: Ergänzt die `TODO` in `miniprojekt/terraform/` und wendet es an: `versions.tf`, `variables.tf` und `outputs.tf` schreibt ihr selbst, in `main.tf` fehlen der Schlüssel (`local_sensitive_file`), der Pfad zum Dockerfile, Server `db1`, das Subnetz, die Eingaben des Moduls und die Werte für das Inventory. Zu jeder Lücke steht ein Muster dabei. Es baut Netz, zwei Server und das Inventory mit den Gruppen `app` und `db`.
2. **Rolle `postgresql`**: Ergänzt die `TODO` in `ansible/roles/postgresql/tasks/main.yml` (Konfiguration, Zugriffsregel, Dienst, Benutzer, Datenbank).
3. **Rolle `app`**: Ergänzt die `TODO` in `ansible/roles/app/tasks/main.yml` (Benutzer, Verzeichnis, Vorlagen, Dienst). Vorlagen und Handler sind schon fertig.
4. **Test und Neuaufbau**: Smoke-Test, `destroy`, alles von vorn.

## Ablauf

```bash
cd miniprojekt/terraform
terraform init && terraform apply
cd ../ansible
ansible-playbook site.yml
curl http://127.0.0.1:8080/        # Antwort mit "DB OK"
curl http://127.0.0.1:8080/health  # ok
ansible-playbook site.yml          # zweiter Lauf: changed=0
```

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
