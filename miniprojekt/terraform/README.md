# Miniprojekt: der Terraform-Teil

Dieser Ordner baut die Infrastruktur für das Miniprojekt: ein Netz, zwei Server (`app1` und `db1`), einen SSH-Schlüssel und die Datei `../ansible/inventory.ini`, mit der Ansible danach weiterarbeitet. Die Server sind Docker-Container mit systemd und SSH, so wie in `umgebung/`.

```
Terraform (hier)                                     Ansible (../ansible)
 Schlüssel + Image + Netz + 2 Server + Inventory --> richtet Datenbank und Anwendung ein
```

## Was ihr schreibt

| Datei | Euer Teil |
| --- | --- |
| `versions.tf` | der `terraform`-Block mit den drei Providern (`docker`, `tls`, `local`) und `provider "docker"` |
| `variables.tf` | die Variablen `umgebung`, `netz`, `app_port` |
| `outputs.tf` | die Ausgaben `app_url`, `ssh`, `db_ip` |
| `main.tf` | Lücken mit `TODO`: Schlüsseldatei, Pfad zum Dockerfile, Eintrag `db1`, Subnetz, Modulaufruf, Werte für das Inventory |

Bei jeder Lücke steht ein Muster (meist `umgebung/` oder Lab 2). Die Vorlage `templates/inventory.tftpl` ist fertig.

## Checkpoints mit `pruefen.sh`

`pruefen.sh` prüft, ob euer letzter Schritt funktioniert, bevor ihr weitermacht. Es ändert nichts, es liest nur: Terraform-Code, den Zustand und Docker.

### Aufruf

Im Ordner `miniprojekt/terraform`, ein Checkpoint pro Aufruf:

```bash
bash pruefen.sh init        # 1: nach versions.tf
bash pruefen.sh variablen   # 2: nach variables.tf
bash pruefen.sh validate    # 3: nach main.tf (ohne db1) und outputs.tf
bash pruefen.sh plan        # 4: nach dem Eintrag db1 in den locals
bash pruefen.sh apply       # 5: nach terraform apply
bash pruefen.sh             # alle fünf nacheinander
```

### Der Ablauf

| # | Ihr habt gerade | Dann ausführen | Es prüft | Grün heißt |
| --- | --- | --- | --- | --- |
| 1 | `versions.tf` geschrieben | `bash pruefen.sh init` | führt `terraform init` aus und sucht die Provider in `.terraform.lock.hcl` | Init läuft, `kreuzwerker/docker`, `hashicorp/tls`, `hashicorp/local` sind geladen |
| 2 | `variables.tf` geschrieben | `bash pruefen.sh variablen` | liest die Standardwerte mit `terraform console` | `"schulung"`, `"172.30.0.0/24"` (Text) und `8080` (Zahl) |
| 3 | Schlüssel, Dockerfile-Pfad, Subnetz, Modulaufruf, Inventory-Werte und `outputs.tf` geschrieben | `bash pruefen.sh validate` | `terraform validate`, die Ressourcen und Ausgaben stehen im Code, kein `TODO` mehr in `main.tf`, `terraform fmt` | keine Fehlermeldung, alles `OK:` |
| 4 | Eintrag `db1` in den `locals` geschrieben | `bash pruefen.sh plan` | liest `local.server` und `local.rollen` aus und führt `terraform plan` aus | `db1` hat IP 172.30.0.21, Port 2202, Rolle `db`, keine Ports. Bei leerem Zustand `Plan: 7 to add` |
| 5 | `terraform apply` ausgeführt | `bash pruefen.sh apply` | `terraform output`, Rechte der Schlüsseldatei, `../ansible/inventory.ini`, Docker (Container, Subnetz, Ports) | Ausgaben stimmen, Schlüssel hat 0600, Inventory vollständig, zwei Container laufen, `db1` veröffentlicht 5432 nicht |

Der Ablauf im Ganzen:

```bash
cd miniprojekt/terraform
# versions.tf schreiben
bash pruefen.sh init
# variables.tf schreiben
bash pruefen.sh variablen
# main.tf und outputs.tf schreiben
bash pruefen.sh validate
# Eintrag db1 schreiben
bash pruefen.sh plan
terraform apply
bash pruefen.sh apply
```

Ist Checkpoint 5 grün, geht es mit Ansible weiter (Anleitung in `../README.md`):

```bash
cd ../ansible
ansible-playbook pruefen.yml --tags verbindung
```

### So lest ihr die Ausgabe

```
===== Checkpoint 2: variables.tf
OK: Variable umgebung ist deklariert
FEHLT: Variable netz ist deklariert. Hinweis: variable "netz" in variables.tf (type und default)
FEHLT: netz hat den Standardwert 172.30.0.0/24 (gefunden: nichts, erwartet: "172.30.0.0/24"). Hinweis: default in variables.tf (Text in Anfuehrungszeichen)

Ergebnis: 2 Pruefung(en) fehlgeschlagen
```

- `OK:` heißt: Das stimmt.
- `FEHLT:` nennt, was nicht stimmt. Nach `Hinweis:` steht die Stelle, die ihr euch ansehen sollt.
- Bei Vergleichen steht `gefunden` (was euer Code liefert) und `erwartet` (was richtig wäre). Texte erscheinen in Anführungszeichen, Zahlen ohne. Ein `"8080"` mit Anführungszeichen ist also Text, keine Zahl.
- Alle Prüfungen eines Checkpoints laufen durch, damit ihr alle Fehler auf einmal seht.
- Am Ende steht `Ergebnis: N Pruefung(en) fehlgeschlagen`. Bei `0` ist der Checkpoint grün. Der Exit-Code des Skripts ist dieselbe Zahl.

### Häufige Meldungen

| Meldung | Bedeutung |
| --- | --- |
| `Provider fehlen noch. Hinweis: zuerst bash pruefen.sh init` | Ihr seid zu weit vorn. Checkpoint 1 zuerst grün machen. |
| `terraform validate meldet Fehler` | Darunter stehen die ersten Zeilen der Terraform-Meldung: fehlende Ressource, Variable oder Tippfehler im Namen. Die ganze Meldung seht ihr mit `terraform validate`. |
| `terraform plan schlaegt fehl` | Meist steht noch ein Wert `null` oder ein `TODO` im Code, oder `db1` fehlt. Die ganze Meldung seht ihr mit `terraform plan`. |
| `Noch keine Ausgaben` | `terraform apply` ist noch nicht gelaufen oder `outputs.tf` ist leer. |
| `Container ... laeuft` fehlt | Der Modulaufruf ist unvollständig, oder `docker ps` zeigt, was wirklich läuft. |

### Die Zeile `INFO` nach dem apply

```
INFO: terraform plan zeigt noch Aenderungen. ...
```

Manche Docker-Umgebungen melden nach dem `apply` Unterschiede im Netz und in den Containern, obwohl ihr nichts geändert habt (Eigenheit des Docker-Providers). Das ist kein Fehler und zählt nicht mit. Führt dann **kein weiteres `terraform apply`** aus: Terraform würde die Server neu bauen, und Ansible müsste danach noch einmal laufen.

## Nützliche Terraform-Befehle, wenn ein Checkpoint rot ist

```bash
terraform fmt           # bringt die Dateien ins Standardformat
terraform validate      # prüft den Code ohne Server
terraform plan          # zeigt, was Terraform tun würde
terraform output        # zeigt die Ausgaben nach einem apply
terraform console       # Ausdrücke ausprobieren, z. B. local.server oder var.netz
terraform state list    # zeigt, was Terraform verwaltet
```

## Aufräumen

```bash
terraform destroy
```
