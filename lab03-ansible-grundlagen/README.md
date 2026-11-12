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

## Fragen und Antworten

### Warum richten wir nginx im Container ein?

Der Container ist hier nur ein Ersatz für einen Server. nginx ist das Beispiel, an dem Ansible etwas zu tun hat.

1. **Der Server kommt leer an.** Das Image enthält systemd und SSH, aber kein nginx. Ansible hat also echte Arbeit: installieren, konfigurieren, starten. Wäre nginx schon im Image, würde der zweite Lauf mit `changed=0` nichts zeigen.
2. **nginx deckt die Grundbausteine ab.** `apt` installiert, `template` erzeugt Startseite und Konfiguration, `service` startet den Dienst, `notify` und Handler laden bei geänderter Konfiguration neu.
3. **Das Ergebnis ist sichtbar.** Das zweite Play ruft die Seite ab und prüft, ob der Servername darin steht.
4. **Der Port zeigt Check- und Diff-Modus.** `web_port` steckt in der Konfiguration. Mit `-e web_port=8081` seht ihr erst die Vorschau und dann den Handler.

nginx ist austauschbar. Jeder Dienst mit Paket, Konfiguration und Port (zum Beispiel Apache) lehrt dasselbe.

### Gibt es nicht Docker-Images, in denen nginx schon drin ist?

Ja, das offizielle `nginx`-Image. Im Docker-Alltag nimmt man genau das. Für dieses Lab passt es nicht:

- **Ansible konfiguriert Server, keine Images.** Mit dem fertigen Image wäre die Installation schon erledigt, und `apt`, `template` und `service` hätten nichts mehr zu tun.
- **Das Image hat kein systemd und kein SSH.** Es startet nginx als einzigen Prozess. Ansible verbindet sich per SSH und steuert Dienste mit dem Modul `service`, das systemd braucht. Dafür ist unser eigenes Image gebaut.
- **Auf echten Servern gibt es kein fertiges Image.** Dort richtet man den Dienst auf einer laufenden Maschine ein. Das soll das Lab zeigen.

Wer wann welches Werkzeug nimmt:

| Situation | Werkzeug |
| --- | --- |
| Container: nginx ins Image bauen, mit Terraform starten (Image und Instanz, siehe `modules/linux-server/README.md`) | Dockerfile und Terraform |
| Server, der lange läuft und verändert wird: Dienst einrichten und aktuell halten | Ansible |

## Aufräumen

Die Server bleiben für Lab 5 stehen. Zum Beenden: `terraform destroy` im Ordner `umgebung`.
