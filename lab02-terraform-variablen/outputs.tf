# BLOCK output "NAME" { }
# Was: Wert, den Terraform nach apply anzeigt (terraform output) und nach aussen weitergibt.
# Wozu: Ergebnisse sichtbar machen und an andere Module oder Projekte uebergeben.
# sensitive = true blendet den Wert in der Anzeige aus (er steht trotzdem im State).
output "server_dateien" {
  description = "Erzeugte Dateien pro Server"
  value       = { for name, f in local_file.server_info : name => f.filename }
}

output "rollen" {
  value = local.rollen
}

output "db_passwort" {
  value     = random_password.db.result
  sensitive = true
}
