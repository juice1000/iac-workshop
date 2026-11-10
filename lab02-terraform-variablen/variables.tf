# TODO 1: variable "umgebung" (string, Default "schulung"),
#         validation: nur schulung, test oder prod erlaubt
# TODO 2: variable "server": map von Objekten mit rolle (string) und port (number),
#         Default: app1 (Rolle app, Port 2201) und db1 (Rolle db, Port 2202)
#
# OPTIONAL / GUT ZU WISSEN
# - Rangfolge der Werte: Default, terraform.tfvars, *.auto.tfvars, -var-file, -var, Umgebungsvariable TF_VAR_<name>.
# - Weitere Eigenschaften: sensitive = true, nullable = false, description fuer jede Variable.
# - Typen: string, number, bool, list(...), set(...), map(...), object({...}), tuple, any.
# - optional() in Objekten: object({ rolle = string, port = optional(number, 22) })
# - Mehrere validation-Bloecke sind erlaubt, z. B. Port zwischen 1024 und 65535.
# - terraform.tfvars.example zeigt, wie man Werte ohne Aenderung der Dateien setzt.
