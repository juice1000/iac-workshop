output "server_dateien" {
  description = "Erzeugte Dateien pro Server"
  value       = { for name, f in local_file.server_info : name => f.filename }
}

# TODO: output "rollen" mit local.rollen

# TODO: output "db_passwort" mit dem Ergebnis von random_password.db (Attribut result)
#       Der Wert ist geheim: sensitive = true

#
# OPTIONAL / GUT ZU WISSEN
# - terraform output -raw db_passwort zeigt auch sensitive Werte. Im State stehen sie im Klartext.
# - Outputs sind die Schnittstelle zwischen Modulen und zwischen Terraform-Projekten (terraform_remote_state).
# - output-Bloecke koennen eine precondition haben.
