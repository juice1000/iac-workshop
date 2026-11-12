# Miniprojekt: Anwendungsserver mit Datenbankserver

> Branch `practice-solved`: Die Lücken (`TODO`) sind hier schon ausgefüllt, inklusive der optionalen Beispiele. Zum Vergleichen mit der eigenen Lösung.

## Ziel

Alles zusammen, wie im Alltag: Terraform baut die Infrastruktur, Ansible konfiguriert sie. Ihr richtet einen Anwendungsserver ein, der mit einem entfernten PostgreSQL-Server spricht.

```
Browser/curl --> app1 (Python-Anwendung) --> db1 (PostgreSQL)
```

Am Ende antwortet die Anwendung mit `Hallo von tlbg-schulung-app1! DB OK (...), Besuche: N`. Die Datenbank ist von außen nicht erreichbar (Port 5432 nur im Anwendungsnetz).

## Phasen

1. **Terraform** (geführt): `miniprojekt/terraform` lesen und anwenden. Es baut Netz, zwei Server und das Inventory mit den Gruppen `app` und `db`.
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

## Aufräumen

```bash
cd miniprojekt/terraform
terraform destroy
```
