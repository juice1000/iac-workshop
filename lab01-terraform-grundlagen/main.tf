# Lab 1: Terraform-Grundlagen
# Zwei Provider, die keine Cloud brauchen: random und local.

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
  }
}

# BLOCK resource "TYP" "NAME" { }
# Was: beschreibt ein Objekt, das Terraform anlegen und verwalten soll. TYP sagt was (Provider und Art),
#      NAME ist der Name im Code. Zusammen ergeben sie die Adresse, z. B. random_pet.server_name.
# Wozu: das ist der Kern von Terraform. Man beschreibt den Zielzustand, Terraform vergleicht ihn mit
#       dem State und berechnet, was angelegt, geaendert oder geloescht werden muss (plan, apply).
# Verweise wie random_pet.server_name.id legen die Reihenfolge fest (implizite Abhaengigkeit).
# Erzeugt einen zufaelligen Namen, z. B. "brave-otter"
resource "random_pet" "server_name" {
  length = 2
}

# Schreibt eine Datei. Der Inhalt haengt von random_pet ab (implizite Abhaengigkeit).
resource "local_file" "hallo" {
  filename = "${path.module}/out/hallo.txt"
  content  = "Hallo Terraform! Servername: ${random_pet.server_name.id}\n"
}
