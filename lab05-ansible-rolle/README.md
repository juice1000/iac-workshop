# Lab 5: Ansible-Rollen

## Ziel

Die Aufgaben aus Lab 3 wandern in eine Rolle. Das Playbook wird kurz, die Rolle lässt sich in anderen Projekten wiederverwenden und über Variablen anpassen.

Am Ende könnt ihr erklären:

- die Ordnerstruktur einer Rolle (`tasks`, `defaults`, `handlers`, `templates`)
- warum Rollenvariablen den Rollennamen als Präfix tragen (`webserver_...`)
- wie Variablen-Vorrang funktioniert: Defaults sind am schwächsten, `-e` gewinnt

## Voraussetzung

Die Server aus `umgebung/` laufen (siehe Lab 3). `ansible.cfg` nutzt das Inventory aus Lab 3.

## Aufgabe

Auf dem Branch `start` ist dieses Lab fertig ausgefüllt. Ihr geht es gemeinsam durch, führt es aus und nutzt es im Miniprojekt als Vorlage. Zum Selbstüben gibt es auf `practice` die Version mit Lücken. Über den Blöcken steht, was sie tun. Die Rolle liegt in `roles/webserver/` (Aufgaben, Standardwerte, Handler). `site.yml` ruft die Rolle nur noch auf.

## Ablauf

```bash
cd lab05-ansible-rolle
ansible-playbook site.yml    # erster Lauf
ansible-playbook site.yml    # zweiter Lauf: changed=0
```

## Dinge zum Ausprobieren

- `site.yml` setzt `webserver_begruessung`. Löscht die Zeile: dann gilt der Default aus `defaults/main.yml`.
- Überschreibt den Port auf der Kommandozeile: `ansible-playbook site.yml -e webserver_port=8082`. Das gewinnt gegen alles andere.
- Vault: `ansible-vault create vault.yml` legt eine verschlüsselte Datei an, `--ask-vault-pass` entschlüsselt sie beim Lauf.
