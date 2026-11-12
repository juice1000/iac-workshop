# Übungsserver

## Ziel

Die Ansible-Labs brauchen Server. Hier baut Terraform sie als Docker-Container mit Ubuntu 24.04, systemd und SSH. Für Ansible verhalten sie sich wie kleine VMs. Das ist zugleich ein Beispiel dafür, dass Terraform nicht nur Dateien, sondern echte Infrastruktur anlegt.

## Was entsteht

- ein Docker-Image (Ubuntu mit SSH und systemd)
- ein Netz `tlbg-umgebung`
- zwei Server `server1` und `server2` (über das Modul `modules/linux-server`)
- ein SSH-Schlüssel
- `lab03-ansible-grundlagen/inventory.ini` mit der Gruppe `web`: Terraform übergibt die Server an Ansible

## Aufbau

Dieselbe Trennung wie in Lab 2:

| Datei | Inhalt |
| --- | --- |
| `versions.tf` | Terraform-Version, Provider (docker, tls, local), Docker-Anbindung |
| `variables.tf` | Eingabe `server`: Name, SSH-Port und IP der Server |
| `main.tf` | Schlüssel, Image, Netz, Server (Modul `../modules/linux-server`), Inventory |
| `outputs.tf` | SSH-Befehl pro Server |
| `templates/inventory.tftpl` | Vorlage für das Ansible-Inventory |

Wollt ihr einen dritten Server, ergänzt ihr in `variables.tf` einen Eintrag mit freiem Port und freier IP im Netz `172.31.0.0/24`. Alles andere ergibt sich daraus.

## Ausführen

```bash
cd umgebung
terraform init
terraform apply     # der Image-Bau dauert einige Minuten
docker ps           # beide Container laufen
```

Startet den Apply früh, dann baut er im Hintergrund, während ihr `erste-schritte/ansible` macht.

## Aufräumen

```bash
terraform destroy
```

Nach einem Neustart des Rechners oder zurückgesetztem Desktop startet ihr die Umgebung mit `terraform apply` neu.
