# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.
# ZUSATZMATERIAL (Branch additional-material): alle TODOs sind ausgefuellt, die optionalen Beispiele sind aktiv.
# Beispiele mit [NICHT AKTIV] bleiben bewusst auskommentiert, der Grund steht dabei.
# Optional in dieser Datei: terraform output -raw und -json, precondition am Output.

# BLOCK output "NAME" { }
# Was: Wert, den Terraform nach apply anzeigt (terraform output) und nach aussen weitergibt.
# Wozu: Ergebnisse sichtbar machen und an andere Module oder Projekte uebergeben.
# sensitive = true blendet den Wert in der Anzeige aus (er steht trotzdem im State).
output "server_dateien" {
  description = "Erzeugte Dateien pro Server"
  value       = { for name, f in local_file.server_datei : name => f.filename }
}

output "rollen" {
  value = local.rollen

  precondition {
    condition     = length(local.rollen) > 0
    error_message = "Es gibt keine Rollen."
  }
}

output "db_passwort" {
  value     = random_password.db.result
  sensitive = true
}
# OPTIONAL: sensitive Werte anzeigen:  terraform output -raw db_passwort
#           Im State stehen sie trotzdem im Klartext.
# OPTIONAL: Pruefung am Output (in den output-Block schreiben)
# Aktiv: die precondition steht oben im Output "rollen".
# OPTIONAL: Output als JSON:  terraform output -json
