# Terraform & Ansible: Einstieg (TLBG)

Übungsmaterial für den 2-tägigen Workshop. Jeder Ordner ist ein Lab.

## Voraussetzungen

- Linux-Umgebung (Linux-VM oder WSL unter Windows)
- Terraform >= 1.6, Ansible, Git, Docker, Python 3, SSH-Client
- Prüfen: `bash lab00-check/check.sh`
- Windows-Rechner im Kurs: siehe "Rechner einrichten" unten

## Rechner einrichten (Windows mit WSL)

Auf den Kursrechnern läuft Windows. Ansible, Docker und die Labs laufen in Ubuntu
unter WSL. Das richtet ihr einmal ein (etwa 10 Minuten).

**1. PowerShell** (als Administrator öffnen: Startmenü, "PowerShell" rechtsklicken, "Als Administrator ausführen"):

```powershell
wsl --install -d Ubuntu-24.04
```

Ubuntu öffnet sich und fragt nach einem Benutzernamen und einem Passwort. Beides
selbst wählen und merken, das Passwort braucht ihr gleich für `sudo`. Die Meldung
zur "geschachtelten Virtualisierung" ist nur ein Hinweis und kann ignoriert werden.

**2. In Ubuntu** (nicht in PowerShell) einfügen:

```bash
cd ~ && git clone -b start https://github.com/juice1000/iac-workshop.git && cd iac-workshop && bash setup-wsl.sh
```

Das Skript installiert Docker, Ansible und Terraform und prüft am Ende alles. Es
fragt einmal nach dem Passwort. Am Ende steht `Ergebnis: 15 OK, 0 fehlend`.

**3. Ubuntu-Fenster schließen und neu öffnen**, dann testen: `docker ps`
(eine leere Tabelle ist richtig).

Kommt eine Fehlermeldung? Skript einfach noch einmal starten, es ist gefahrlos
wiederholbar. Hilft das nicht: Ausgabe kopieren und im Chat zeigen.

Wichtig: Das Repository immer im Linux-Home (`~`) ablegen, nicht unter `/mnt/c`.

## Repository holen

```bash
git clone <URL-des-Repositorys>
cd <Ordnername>
git pull   # später: neuesten Stand holen
```

In VS Code: Ansicht "Quellcodeverwaltung" > "Repository klonen".

## Ablauf

| Ordner | Wann | Inhalt |
| --- | --- | --- |
| `lab00-check` | Tag 1, Start | Werkzeuge und Netzwerk prüfen |
| `erste-schritte/terraform` | Tag 1, vor Lab 1 | Terraform-Befehle ausprobieren, ohne Provider und ohne Internet |
| `lab01-terraform-grundlagen` | Tag 1 | init, plan, apply, destroy, State |
| `lab02-terraform-variablen` | Tag 1 | Variablen, Locals, for_each, Outputs, Vorlagen |
| `umgebung` | Tag 1 | Startet zwei Linux-Server für die Ansible-Labs |
| `erste-schritte/ansible` | Tag 1, vor Lab 3 | Ansible-Befehle und Module am eigenen Rechner ausprobieren, ohne Server |
| `lab03-ansible-grundlagen` | Tag 1 | Inventory, Ad-hoc, Playbook, Vorlagen, Handler |
| `lab04-terraform-module` | Tag 2 | Lab 2 als Modul |
| `lab05-ansible-rolle` | Tag 2 | Lab 3 als Rolle |
| `miniprojekt` | Tag 2 | Anwendungsserver mit entferntem DB-Server |

## Erste Schritte auf der Kommandozeile

Beide Ordner unter `erste-schritte/` enthalten ein Skript `rundgang.sh`, das die
wichtigsten Befehle der Reihe nach zeigt und ausführt. Am meisten lernt ihr, wenn
ihr die Befehle selbst tippt. Wer festhängt, startet den Rundgang:

```bash
cd erste-schritte/terraform && bash rundgang.sh
cd erste-schritte/ansible && bash rundgang.sh
```

## Übungsserver

Die "Server" sind Docker-Container mit Ubuntu 24.04, systemd und SSH
(`docker/Dockerfile`). Für Ansible verhalten sie sich wie kleine VMs.
Terraform baut Image, Netz und Container und schreibt das Ansible-Inventory.

```bash
cd umgebung
terraform init
terraform apply
```

## Miniprojekt in Kurzform

```bash
cd miniprojekt/terraform
terraform init && terraform apply
cd ../ansible
ansible-playbook site.yml
curl http://127.0.0.1:8080/
```

Aufräumen: `terraform destroy` im jeweiligen Terraform-Ordner.

## Probelauf fuer den Trainer

`bash scripts/dry-run.sh` baut alle Labs nacheinander auf, prueft die Ergebnisse
und die Idempotenz und raeumt danach auf. Derselbe Lauf passiert bei jedem Push
auf GitHub (Actions, Workflow "Test").
