# Lab 1: Terraform-Grundlagen (Uebung)
# Ziel: out/hallo.txt mit "Hallo Terraform! Servername: <zufaelliger Name>"
# Ergaenzt die Stellen mit TODO.
# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.

# TODO: terraform-Block mit required_version >= 1.6 und required_providers
#       random (hashicorp/random, ~> 3.6) und local (hashicorp/local, ~> 2.5)

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
# OPTIONAL: weitere Argumente von local_file (in den Block schreiben)
#   file_permission      = "0600"
#   directory_permission = "0700"
#   depends_on           = [random_pet.server_name]   # nur bei versteckten Abhaengigkeiten
# OPTIONAL: lifecycle (in den Block schreiben)
#   lifecycle {
#     prevent_destroy = true        # destroy bricht ab
#     ignore_changes  = [content]   # Aenderungen von Hand werden ignoriert
#   }

# OPTIONAL: eine vorhandene Datei lesen (data-Block) und ausgeben
#   data "local_file" "gelesen" {
#     filename   = local_file.hallo.filename
#     depends_on = [local_file.hallo]
#   }
#   output "inhalt" {
#     value = data.local_file.gelesen.content
#   }

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
