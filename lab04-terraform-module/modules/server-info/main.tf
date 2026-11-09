terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "info" {
  filename = "${var.ausgabe_ordner}/${var.prefix}-${var.name}.txt"
  content  = "Server ${var.name}, Rolle ${var.rolle}, SSH-Port ${var.port}\n"
}
