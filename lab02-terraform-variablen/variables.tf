variable "umgebung" {
  description = "Name der Umgebung, wird als Praefix verwendet"
  type        = string
  default     = "schulung"

  # TODO: validation-Block: nur "schulung", "test" oder "prod" erlaubt
  #       Tipp: condition mit contains(), dazu error_message
}

variable "server" {
  description = "Server mit Rolle und SSH-Port"
  # TODO: type = map(object({ ... })) mit rolle (string) und port (number)
  default = {
    app1 = { rolle = "app", port = 2201 }
    db1  = { rolle = "db", port = 2202 }
  }
}

#
# OPTIONAL / GUT ZU WISSEN
# - Rangfolge der Werte: Default, terraform.tfvars, *.auto.tfvars, -var-file, -var, Umgebungsvariable TF_VAR_<name>.
# - Weitere Eigenschaften: sensitive = true, nullable = false, description fuer jede Variable.
# - Typen: string, number, bool, list(...), set(...), map(...), object({...}), tuple, any.
# - optional() in Objekten: object({ rolle = string, port = optional(number, 22) })
# - Mehrere validation-Bloecke sind erlaubt, z. B. Port zwischen 1024 und 65535.
# - terraform.tfvars.example zeigt, wie man Werte ohne Aenderung der Dateien setzt.
