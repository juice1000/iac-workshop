# Lab 4: Terraform-Module

> Branch `practice-solved`: Die Lücken (`TODO`) sind hier schon ausgefüllt, inklusive der optionalen Beispiele. Zum Vergleichen mit der eigenen Lösung.

## Ziel

Lab 2 war ein einziger Ordner mit allem darin. Hier zerlegt ihr denselben Code in ein wiederverwendbares Modul. Was man mehrfach braucht, schreibt man einmal und ruft es mit verschiedenen Eingaben auf.

Am Ende könnt ihr erklären:

- Eingang (Variablen), Ausgang (Outputs) und Kapselung eines Moduls
- wie `for_each` pro Eintrag eine Modulinstanz erzeugt
- wie Adressen aussehen, zum Beispiel `module.server_info["app1"].local_file.info`

## Aufbau

```
main.tf                       Root-Modul: ruft das Modul pro Server auf
modules/server-info/
  main.tf                     die Ressource
  variables.tf                Eingaben des Moduls
  outputs.tf                  Ausgaben des Moduls
```

## Aufgabe

Ergänzt die Stellen mit `TODO` im Root-Modul und im Modul. Über jedem Block steht, was er tut und wozu. Ergebnis: für `app1` und `db1` entsteht je eine Datei in `out/`, wie in Lab 2.

## Ablauf

```bash
cd lab04-terraform-module
terraform init
terraform plan
terraform apply
terraform state list     # Adressen mit module.server_info[...]
terraform output
```

## Dinge zum Ausprobieren

- Fügt in `variable "server"` einen dritten Server hinzu und führt `plan` aus. Nur die neue Instanz kommt dazu.
- Startet `terraform plan -var 'umgebung=test'` und schaut euch die Dateinamen an.

## Aufräumen

```bash
terraform destroy
```
