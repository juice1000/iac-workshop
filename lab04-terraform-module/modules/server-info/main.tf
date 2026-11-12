# GELOESTE VERSION von practice: alle TODOs sind ausgefuellt, die optionalen Beispiele sind aktiv.
# Beispiele mit [NICHT AKTIV] bleiben bewusst auskommentiert, der Grund steht dabei.
# Optional in dieser Datei: required_version im Modul.
# Im Modul reicht required_providers: es sagt, welchen Provider das Modul braucht.
# Der Provider selbst wird nicht im Modul konfiguriert, sondern vom Aufrufer (Root-Modul).
# Ein Modul besteht ueblich aus main.tf (Ressourcen), variables.tf (Eingaben) und outputs.tf (Ausgaben).
terraform {
  required_version = ">= 1.6"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
# OPTIONAL: Version von Terraform fordern (in den terraform-Block schreiben)
# Aktiv: required_version steht oben im terraform-Block.
# Ein Modul konfiguriert keine Provider. Das macht der Aufrufer.

resource "local_file" "info" {
  filename = "${var.ausgabe_ordner}/${var.prefix}-${var.name}.txt"
  content  = "Server ${var.name}, Rolle ${var.rolle}, SSH-Port ${var.port}\n"
}
