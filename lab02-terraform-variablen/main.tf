# Lab 2: Variablen, Locals, for_each, Outputs, templatefile

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

locals {
  prefix = "tlbg-${var.umgebung}"
  rollen = sort(distinct([for s in var.server : s.rolle]))
}

# Ein Passwort, das Terraform erzeugt. Achtung: es landet im State!
resource "random_password" "db" {
  length  = 20
  special = false
}

# Eine Datei pro Server (for_each ueber eine Map)
resource "local_file" "server_info" {
  for_each = var.server

  filename = "${path.module}/out/${local.prefix}-${each.key}.txt"
  content  = "Server ${each.key}, Rolle ${each.value.rolle}, SSH-Port ${each.value.port}\n"
}

# Ansible-Inventory aus einer Vorlage erzeugen
resource "local_file" "inventory" {
  filename = "${path.module}/out/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    server = var.server
    rollen = local.rollen
  })
}
