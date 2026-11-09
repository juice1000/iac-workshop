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
