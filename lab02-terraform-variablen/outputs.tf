# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.

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
# OPTIONAL: sensitive Werte anzeigen:  terraform output -raw db_passwort
#           Im State stehen sie trotzdem im Klartext.
# OPTIONAL: Pruefung am Output (in den output-Block schreiben)
#   precondition {
#     condition     = length(local.rollen) > 0
#     error_message = "Es gibt keine Rollen."
#   }
# OPTIONAL: Output als JSON:  terraform output -json
