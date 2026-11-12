# Lab 0: Werkzeuge und Netzwerk prüfen

## Ziel

Bevor ihr loslegt, prüft ein Skript, ob euer Rechner alles hat, was die Labs brauchen. Ein Fehler hier kostet fünf Minuten, ein Fehler mitten in Lab 3 kostet deutlich mehr.

## Ausführen

```bash
bash lab00-check/check.sh
```

## Was geprüft wird

- Programme: Terraform (mindestens 1.6), Ansible, Git, Docker, Python 3, SSH
- Die Ansible-Collection `community.postgresql` (für das Miniprojekt)
- Der Docker-Dienst läuft
- Netzwerk: Terraform Registry, GitHub, Ansible Galaxy, Docker Hub, Ubuntu-Paketquellen

## Erwartetes Ergebnis

Am Ende steht `Ergebnis: 15 OK, 0 fehlend`. Bei fehlenden Punkten zeigt das Skript, was fehlt. Zeigt die Meldung im Chat, wir klären es gemeinsam.
