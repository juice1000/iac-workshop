# Lab 1: Terraform-Grundlagen

> Branch `additional-material`: Zusatzmaterial. Die Lücken (`TODO`) sind hier schon ausgefüllt, inklusive der optionalen Beispiele. Zum Vergleichen mit der eigenen Lösung.

## Ziel

Ihr erlebt den Terraform-Ablauf zum ersten Mal komplett: schreiben, planen, anwenden, ändern, zerstören. Dafür braucht ihr keine Cloud. Die zwei Provider `random` und `local` genügen: Terraform erzeugt einen zufälligen Namen und schreibt eine Datei.

Am Ende könnt ihr erklären:

- was ein Provider, eine Ressource und der State sind
- warum ein zweiter `apply` nichts mehr ändert (Idempotenz)
- was Terraform tut, wenn sich etwas ändert oder jemand die Datei von Hand löscht

## Aufgabe

Öffnet `main.tf`. Über jedem Block steht, was er tut und wozu. Ergänzt die Stellen mit `TODO`, bis `out/hallo.txt` entsteht mit dem Inhalt:

```
Hallo Terraform! Servername: brave-otter
```

(Der Name ist zufällig.)

## Ablauf

```bash
cd lab01-terraform-grundlagen
terraform init       # Provider herunterladen
terraform fmt        # Code formatieren
terraform validate   # Syntax und Verweise prüfen
terraform plan       # Vorschau: was würde passieren?
terraform apply      # anwenden, mit "yes" bestätigen
cat out/hallo.txt
terraform state list
terraform apply      # zweiter Lauf: keine Änderungen
```

## Dinge zum Ausprobieren

- Ändert den Text in `content` und führt `plan` aus. Terraform zeigt `-/+` (ersetzen), weil eine Datei nicht an Ort und Stelle geändert wird.
- Löscht `out/hallo.txt` von Hand und führt `plan` aus. Terraform erkennt die Abweichung vom State und legt die Datei neu an (Drift).
- Schaut in `terraform.tfstate`. Dort merkt sich Terraform, was es angelegt hat.

## Aufräumen

```bash
terraform destroy
```
