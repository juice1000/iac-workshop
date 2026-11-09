# Lab 1: Terraform-Grundlagen
# Zwei Provider, die keine Cloud brauchen: random und local.

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

# Erzeugt einen zufaelligen Namen, z. B. "brave-otter"
resource "random_pet" "server_name" {
  length = 2
}

# Schreibt eine Datei. Der Inhalt haengt von random_pet ab (implizite Abhaengigkeit).
resource "local_file" "hallo" {
  filename = "${path.module}/out/hallo.txt"
  content  = "Hallo Terraform! Servername: ${random_pet.server_name.id}\n"
}
