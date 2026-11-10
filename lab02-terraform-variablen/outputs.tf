# TODO 1: output "server_dateien": Map Servername -> Dateiname
# TODO 2: output "rollen"
# TODO 3: output "db_passwort", als sensitive markiert
#
# OPTIONAL / GUT ZU WISSEN
# - terraform output -raw db_passwort zeigt auch sensitive Werte. Im State stehen sie im Klartext.
# - Outputs sind die Schnittstelle zwischen Modulen und zwischen Terraform-Projekten (terraform_remote_state).
# - output-Bloecke koennen eine precondition haben.
