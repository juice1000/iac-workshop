# Lab 1: Terraform-Grundlagen (Uebung)
# Ziel: out/hallo.txt mit "Hallo Terraform! Servername: <zufaelliger Name>"
# Ergaenzt die Stellen mit TODO.
# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.

# BLOCK terraform { }
# Was: Einstellungen fuer Terraform selbst, kein Teil der Infrastruktur.
# Wozu: legt fest, welche Terraform-Version laufen darf (required_version) und welche Provider
#       mit welcher Version geladen werden (required_providers). Ohne diese Angaben kann ein Update
#       still das Verhalten aendern.
# Ein Provider ist ein Plugin, das Terraform eine Art von Ressourcen beibringt (hier random und local).
# TODO: terraform-Block mit required_version >= 1.6 und required_providers
#       random (hashicorp/random, ~> 3.6) und local (hashicorp/local, ~> 2.5)

# BLOCK backend (im terraform-Block)
# Was: sagt, wo Terraform den State speichert. Der State ist die Datei, in der Terraform festhaelt,
#      welche echten Objekte zu welchen Ressourcen im Code gehoeren.
# Wozu: Standard ist eine lokale Datei terraform.tfstate. Im Team braucht man einen gemeinsamen Ort
#       (S3, GitLab, http) mit Locking, damit nicht zwei Personen gleichzeitig aendern.
# OPTIONAL: State an einem gemeinsamen Ort ablegen (Zeile im terraform-Block, mit Locking)
#   backend "s3" {
#     bucket = "mein-state-bucket"
#     key    = "lab01/terraform.tfstate"
#     region = "eu-central-1"
#   }
# OPTIONAL: Weiterer Provider im terraform-Block (hier: time fuer Zeitstempel)
#   time = {
#     source  = "hashicorp/time"
#     version = "~> 0.12"
#   }

# BLOCK provider { }
# Was: konfiguriert einen Provider, z. B. Region und Zugangsdaten.
# Wozu: random und local brauchen keine Konfiguration. Echte Clouds schon. Mit alias nutzt man
#       denselben Provider mehrfach (zwei Regionen, zwei Konten). Eine Ressource waehlt ihn mit
#       provider = aws.usa.
# OPTIONAL: Provider konfigurieren, auch mehrfach mit alias (Beispiel mit zwei Regionen)
#   provider "aws" {
#     region = "eu-central-1"
#   }
#   provider "aws" {
#     alias  = "usa"
#     region = "us-east-1"
#   }
#   resource "aws_s3_bucket" "beispiel" {
#     provider = aws.usa
#     bucket   = "beispiel-bucket"
#   }

# BLOCK resource "TYP" "NAME" { }
# Was: beschreibt ein Objekt, das Terraform anlegen und verwalten soll. TYP sagt was (Provider und Art),
#      NAME ist der Name im Code. Zusammen ergeben sie die Adresse, z. B. random_pet.server_name.
# Wozu: das ist der Kern von Terraform. Man beschreibt den Zielzustand, Terraform vergleicht ihn mit
#       dem State und berechnet, was angelegt, geaendert oder geloescht werden muss (plan, apply).
# Verweise wie random_pet.server_name.id legen die Reihenfolge fest (implizite Abhaengigkeit).
# Erzeugt einen zufaelligen Namen, z. B. "brave-otter"
resource "random_pet" "server_name" {
  # TODO: length auf 2 setzen (zwei Woerter)
}
# OPTIONAL: weitere Argumente von random_pet
#   separator = "_"
#   prefix    = "tlbg"
#   keepers   = { version = "1" }   # anderer Wert erzeugt einen neuen Namen

# Schreibt eine Datei. Der Inhalt haengt von random_pet ab (implizite Abhaengigkeit).
resource "local_file" "hallo" {
  # TODO: filename = Datei hallo.txt im Ordner out/ des Moduls (path.module)
  # TODO: content = "Hallo Terraform! Servername: " plus den Namen aus random_pet.server_name
  #       (Attribut id), am Ende ein Zeilenumbruch \n
}
# Zusatz in Ressourcen:
# depends_on: erzwingt eine Reihenfolge, wenn Terraform die Abhaengigkeit nicht aus Verweisen erkennt.
# lifecycle:  steuert, wie Terraform mit der Ressource umgeht (nicht loeschen, Aenderungen ignorieren,
#             erst neu anlegen, dann alte loeschen).
# OPTIONAL: weitere Argumente von local_file (in den Block schreiben)
#   file_permission      = "0600"
#   directory_permission = "0700"
#   depends_on           = [random_pet.server_name]   # nur bei versteckten Abhaengigkeiten
# OPTIONAL: lifecycle (in den Block schreiben)
#   lifecycle {
#     prevent_destroy = true        # destroy bricht ab
#     ignore_changes  = [content]   # Aenderungen von Hand werden ignoriert
#   }

# BLOCK data "TYP" "NAME" { }
# Was: liest etwas Vorhandenes, ohne es zu verwalten (Datei, Image, Netzwerk, Webseite).
# Wozu: man nutzt Werte aus der Aussenwelt im Code, ohne sie neu anzulegen.
# BLOCK output "NAME" { }
# Was: gibt einen Wert nach dem Apply aus (terraform output). Wozu: Ergebnisse anzeigen und
#      an andere Module oder Projekte weitergeben.
# OPTIONAL: eine vorhandene Datei lesen (data-Block) und ausgeben
#   data "local_file" "gelesen" {
#     filename   = local_file.hallo.filename
#     depends_on = [local_file.hallo]
#   }
#   output "inhalt" {
#     value = data.local_file.gelesen.content
#   }

# terraform_data: eingebaute Ressource ohne Provider. Wozu: Klebstoff, z. B. als Ausloeser, der sich
#                 aendert, wenn sich ein Wert aendert (Nachfolger von null_resource).
# time_static:    speichert einen Zeitpunkt dauerhaft im State (Provider time).
# OPTIONAL: terraform_data als Ausloeser (Ersatz fuer null_resource)
#   resource "terraform_data" "marker" {
#     input = random_pet.server_name.id
#   }
# OPTIONAL: Zeitstempel, der sich nur beim ersten Apply setzt (Provider time)
#   resource "time_static" "erstellt" {}
#   output "erstellt_am" {
#     value = time_static.erstellt.rfc3339
#   }

# Pruefen: terraform init, plan, apply. Zweiter plan muss leer sein. Dann destroy.
# OPTIONAL: nuetzliche Befehle
#   terraform plan -out=plan.tfplan && terraform apply plan.tfplan
#   terraform show
#   terraform state list
#   terraform state show random_pet.server_name
#   terraform apply -replace=random_pet.server_name
#   terraform output
# OPTIONAL: Drift zeigen: out/hallo.txt von Hand aendern, dann terraform plan.
