# BLOCK output "NAME" { }
# Was: Wert, den Terraform nach apply anzeigt (terraform output) und nach aussen weitergibt.
# Wozu: Ergebnisse sichtbar machen und an andere Module oder Projekte uebergeben.
# sensitive = true blendet den Wert in der Anzeige aus (er steht trotzdem im State).
output "server_dateien" {
  description = "Erzeugte Dateien pro Server"
  # TODO: value = Map Servername -> Dateiname (for-Ausdruck ueber local_file.server_info)
}

# TODO: output "rollen" mit local.rollen

# TODO: output "db_passwort" mit dem Ergebnis von random_password.db (Attribut result)
#       Der Wert ist geheim: sensitive = true
