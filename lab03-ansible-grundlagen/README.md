# Lab 3: Ansible-Grundlagen

> Branch `practice-solved`: Die Lücken (`TODO`) sind hier schon ausgefüllt, inklusive der optionalen Beispiele. Zum Vergleichen mit der eigenen Lösung.

## Ziel

Terraform hat die Server angelegt, jetzt konfiguriert Ansible sie. Ihr richtet auf zwei Servern einen Webserver ein und seht, was Ansible von einem Shell-Skript unterscheidet: Es beschreibt den Soll-Zustand und ändert nur, was abweicht (Idempotenz).

Am Ende könnt ihr erklären:

- Inventory, Ad-hoc-Befehl, Playbook, Play, Task, Modul
- wozu `template`, `notify` und Handler da sind
- warum ein zweiter Lauf `changed=0` zeigt

## Voraussetzung

Die Server aus `umgebung/` laufen:

```bash
cd umgebung && terraform init && terraform apply
```

Der Apply schreibt `lab03-ansible-grundlagen/inventory.ini` mit der Gruppe `web`. `ansible.cfg` verweist darauf.

## Aufgabe

Öffnet `playbook.yml`. Über jedem Block steht, was er tut und wozu. Ergänzt die Stellen mit `TODO`. Das Playbook installiert nginx, legt Startseite und Konfiguration aus den Vorlagen in `templates/` an und prüft anschließend, ob die Seite antwortet.

## Ablauf

```bash
cd lab03-ansible-grundlagen
ansible web -m ping                          # sind die Server erreichbar?
ansible web -m command -a "uptime"           # Ad-hoc-Befehl
ansible-playbook playbook.yml                # erster Lauf: changed=5
ansible-playbook playbook.yml                # zweiter Lauf: changed=0
```

## Dinge zum Ausprobieren

- Trockenlauf mit Unterschieden, ohne etwas zu ändern: `ansible-playbook playbook.yml --check --diff -e web_port=8081`
- Port wirklich ändern: `ansible-playbook playbook.yml -e web_port=8081`. Der Handler lädt nginx neu, weil sich die Konfiguration geändert hat.
- Hilfe zu einem Modul: `ansible-doc ansible.builtin.template`

## Aufräumen

Die Server bleiben für Lab 5 stehen. Zum Beenden: `terraform destroy` im Ordner `umgebung`.
