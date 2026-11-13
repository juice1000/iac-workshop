# versions.tf: welche Terraform-Version und welche Provider diese Umgebung braucht.
# terraform init laedt die Provider herunter und schreibt die gewaehlten Versionen in .terraform.lock.hcl.
#
# TODO: Schreibt den terraform-Block und die Konfiguration des Docker-Providers.
#
#   terraform { }          required_version ">= 1.6" und required_providers mit drei Providern:
#     docker               source "kreuzwerker/docker", version "~> 3.0"   (Images, Netze, Container)
#     tls                  source "hashicorp/tls",      version "~> 4.0"   (SSH-Schluesselpaar)
#     local                source "hashicorp/local",    version "~> 2.5"   (Dateien auf dem Rechner)
#   provider "docker" { }  leer, es gilt der lokale Docker-Dienst
#
# "~> 3.0" heisst: jede Version 3.x, aber nicht 4.0.
# Muster: umgebung/versions.tf (dieselben drei Provider)
