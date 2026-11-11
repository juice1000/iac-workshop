# Erste Schritte: Terraform ganz ohne Provider und ohne Internet.
# terraform_data ist in Terraform eingebaut. Es legt nichts an, sondern merkt
# sich nur Werte im State. Ideal, um die Befehle gefahrlos auszuprobieren.

terraform {
  required_version = ">= 1.6"
}

variable "name" {
  description = "Wer begruesst wird"
  type        = string
  default     = "TLBG"
}

locals {
  begruessung = "Hallo ${var.name}!"
  server      = ["app1", "db1"]
}

resource "terraform_data" "beispiel" {
  input = local.begruessung
}

output "begruessung" {
  value = terraform_data.beispiel.output
}

output "anzahl_server" {
  value = length(local.server)
}
