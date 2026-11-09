# Terraform & Ansible: Einstieg (TLBG)

Übungsmaterial für den 2-tägigen Workshop. Jeder Ordner ist ein Lab.

## Voraussetzungen

- Linux-Umgebung (Linux-VM oder WSL unter Windows)
- Terraform >= 1.6, Ansible, Git, Docker, Python 3, SSH-Client
- Prüfen: `bash lab00-check/check.sh`

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
| `lab01-terraform-grundlagen` | Tag 1 | init, plan, apply, destroy, State |
| `lab02-terraform-variablen` | Tag 1 | Variablen, Locals, for_each, Outputs, Vorlagen |
| `umgebung` | Tag 1 | Startet zwei Linux-Server für die Ansible-Labs |
| `lab03-ansible-grundlagen` | Tag 1 | Inventory, Ad-hoc, Playbook, Vorlagen, Handler |
| `lab04-terraform-module` | Tag 2 | Lab 2 als Modul |
| `lab05-ansible-rolle` | Tag 2 | Lab 3 als Rolle |
| `miniprojekt` | Tag 2 | Anwendungsserver mit entferntem DB-Server |

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
