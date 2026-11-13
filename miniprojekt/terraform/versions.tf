# versions.tf: welche Terraform-Version und welche Provider diese Umgebung braucht.
# terraform init laedt die Provider herunter und schreibt die gewaehlten Versionen in .terraform.lock.hcl.
terraform {
  required_version = ">= 1.6"

  # Ein Provider ist ein Plugin, das Terraform eine Art von Ressourcen beibringt.
  # "~> 3.0" heisst: jede Version 3.x, aber nicht 4.0. So bricht ein grosser Versionssprung nichts.
  required_providers {
    # docker: Images, Netze und Container auf dem lokalen Docker (unsere "Server")
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    # tls: erzeugt das SSH-Schluesselpaar
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    # local: schreibt Dateien auf den eigenen Rechner (Schluessel, Inventory)
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# Konfiguration des Docker-Providers. Leer heisst: der Standard, also der lokale Docker-Dienst.
# Nutzt den lokalen Docker-Dienst (Linux/WSL: unix:///var/run/docker.sock)
provider "docker" {}
