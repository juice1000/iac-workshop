# Lab 1: Terraform-Grundlagen (Uebung)
# Ziel: out/hallo.txt mit "Hallo Terraform! Servername: <zufaelliger Name>"
# Geloeste Version, alles ausgefuellt.
# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.
# GELOESTE VERSION von practice: alle TODOs sind ausgefuellt, die optionalen Beispiele sind aktiv.
# Beispiele mit [NICHT AKTIV] bleiben bewusst auskommentiert, der Grund steht dabei.
# Optional in dieser Datei: backend (gemeinsamer State), zweiter Provider time, provider mit
#   alias, weitere Argumente von random_pet und local_file, depends_on, lifecycle, data und
#   output, terraform_data, time_static, nuetzliche Befehle.

# BLOCK terraform { }
# Was: Einstellungen fuer Terraform selbst, kein Teil der Infrastruktur.
# Wozu: legt fest, welche Terraform-Version laufen darf (required_version) und welche Provider
#       mit welcher Version geladen werden (required_providers). Ohne diese Angaben kann ein Update
#       still das Verhalten aendern.
# Ein Provider ist ein Plugin, das Terraform eine Art von Ressourcen beibringt (hier random und local).
terraform {
  required_version = ">= 1.6"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

# [OPTIONAL] BLOCK backend (im terraform-Block)
# Was: sagt, wo Terraform den State speichert. Der State ist die Datei, in der Terraform festhaelt,
#      welche echten Objekte zu welchen Ressourcen im Code gehoeren.
# Wozu: Standard ist eine lokale Datei terraform.tfstate. Im Team braucht man einen gemeinsamen Ort
#       (S3, GitLab, http) mit Locking, damit nicht zwei Personen gleichzeitig aendern.
# OPTIONAL: State an einem gemeinsamen Ort ablegen (Zeile im terraform-Block, mit Locking)
# [NICHT AKTIV] braucht einen S3-Bucket. Einfuegen in den terraform-Block: backend "s3" { bucket, key, region }
# OPTIONAL: Weiterer Provider im terraform-Block (hier: time fuer Zeitstempel)
# Aktiv: der Provider time steht oben im terraform-Block.

# [OPTIONAL] BLOCK provider { }
# Was: konfiguriert einen Provider, z. B. Region und Zugangsdaten.
# Wozu: random und local brauchen keine Konfiguration. Echte Clouds schon. Mit alias nutzt man
#       denselben Provider mehrfach (zwei Regionen, zwei Konten). Eine Ressource waehlt ihn mit
#       provider = aws.usa.
# OPTIONAL: Provider konfigurieren, auch mehrfach mit alias (Beispiel mit zwei Regionen)
# [NICHT AKTIV] braucht einen AWS-Zugang. Beispiel: provider "aws" { alias = "usa"  region = "us-east-1" }, Nutzung mit provider = aws.usa

# BLOCK resource "TYP" "NAME" { }
# Was: beschreibt ein Objekt, das Terraform anlegen und verwalten soll. TYP sagt was (Provider und Art),
#      NAME ist der Name im Code. Zusammen ergeben sie die Adresse, z. B. random_pet.server_name.
# Wozu: das ist der Kern von Terraform. Man beschreibt den Zielzustand, Terraform vergleicht ihn mit
#       dem State und berechnet, was angelegt, geaendert oder geloescht werden muss (plan, apply).
# Verweise wie random_pet.server_name.id legen die Reihenfolge fest (implizite Abhaengigkeit).
# Erzeugt einen zufaelligen Namen, z. B. "brave-otter"
resource "random_pet" "server_name" {
  length    = 2
  separator = "_"
  prefix    = "tlbg"
  keepers   = { version = "1" } # anderer Wert erzeugt einen neuen Namen
}
# OPTIONAL: weitere Argumente von random_pet
# Aktiv: separator, prefix und keepers stehen oben im Block.

# Schreibt eine Datei. Der Inhalt haengt von random_pet ab (implizite Abhaengigkeit).
resource "local_file" "hallo" {
  filename = "${path.module}/out/hallo.txt"
  content  = "Hallo Terraform! Servername: ${random_pet.server_name.id}\n"

  file_permission      = "0600"
  directory_permission = "0700"
  depends_on           = [random_pet.server_name] # nur bei versteckten Abhaengigkeiten

  lifecycle {
    ignore_changes = [content] # Aenderungen von Hand werden ignoriert
    # prevent_destroy = true   # [NICHT AKTIV] destroy bricht ab, dann laeuft der Probelauf nicht durch
  }
}
# [OPTIONAL] Zusatz in Ressourcen:
# depends_on: erzwingt eine Reihenfolge, wenn Terraform die Abhaengigkeit nicht aus Verweisen erkennt.
# lifecycle:  steuert, wie Terraform mit der Ressource umgeht (nicht loeschen, Aenderungen ignorieren,
#             erst neu anlegen, dann alte loeschen).
# OPTIONAL: weitere Argumente von local_file (in den Block schreiben)
# Aktiv: file_permission, directory_permission und depends_on stehen oben im Block.
# OPTIONAL: lifecycle (in den Block schreiben)
# Aktiv: ignore_changes steht oben im Block. prevent_destroy ist auskommentiert.

# [OPTIONAL] BLOCK data "TYP" "NAME" { }
# Was: liest etwas Vorhandenes, ohne es zu verwalten (Datei, Image, Netzwerk, Webseite).
# Wozu: man nutzt Werte aus der Aussenwelt im Code, ohne sie neu anzulegen.
# BLOCK output "NAME" { }
# Was: gibt einen Wert nach dem Apply aus (terraform output). Wozu: Ergebnisse anzeigen und
#      an andere Module oder Projekte weitergeben.
# OPTIONAL: eine vorhandene Datei lesen (data-Block) und ausgeben
data "local_file" "gelesen" {
  filename   = local_file.hallo.filename
  depends_on = [local_file.hallo]
}

output "inhalt" {
  value = data.local_file.gelesen.content
}

# [OPTIONAL] terraform_data: eingebaute Ressource ohne Provider. Wozu: Klebstoff, z. B. als Ausloeser, der sich
#                 aendert, wenn sich ein Wert aendert (Nachfolger von null_resource).
# time_static:    speichert einen Zeitpunkt dauerhaft im State (Provider time).
# OPTIONAL: terraform_data als Ausloeser (Ersatz fuer null_resource)
resource "terraform_data" "marker" {
  input = random_pet.server_name.id
}
# OPTIONAL: Zeitstempel, der sich nur beim ersten Apply setzt (Provider time)
resource "time_static" "erstellt" {}

output "erstellt_am" {
  value = time_static.erstellt.rfc3339
}

# Pruefen: terraform init, plan, apply. Zweiter plan muss leer sein. Dann destroy.
# OPTIONAL: nuetzliche Befehle
#   terraform plan -out=plan.tfplan && terraform apply plan.tfplan
#   terraform show
#   terraform state list
#   terraform state show random_pet.server_name
#   terraform apply -replace=random_pet.server_name
#   terraform output
# OPTIONAL: Drift zeigen: out/hallo.txt von Hand aendern, dann terraform plan.
