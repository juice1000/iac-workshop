# Ein Modul besteht ueblich aus main.tf (Ressourcen), variables.tf (Eingaben) und outputs.tf (Ausgaben).
# Im Modul reicht required_providers: es sagt, welchen Provider das Modul braucht.
# Der Provider selbst wird nicht im Modul konfiguriert, sondern vom Aufrufer (Root-Modul).
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
