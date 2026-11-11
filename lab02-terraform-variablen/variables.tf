# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.

# BLOCK variable "NAME" { }
# Was: ein Eingabewert fuer das Modul (Zugriff: var.name).
# Wozu: gleicher Code, verschiedene Werte (schulung, test, prod). Eigenschaften:
#   type        erlaubte Form des Werts (string, number, bool, list, map, object ...)
#   default     Vorgabe. Ohne default ist die Variable Pflicht.
#   description Beschreibung fuer Leser und terraform docs
#   validation  eigene Pruefung mit Fehlermeldung, bevor etwas passiert
variable "umgebung" {
  description = "Name der Umgebung, wird als Praefix verwendet"
  # TODO: type string, default "schulung"

  # TODO: validation-Block: nur "schulung", "test" oder "prod" erlaubt
  #       Tipp: condition mit contains(), dazu error_message

  # OPTIONAL: zweite Pruefung (mehrere validation-Bloecke sind erlaubt)
  #   validation {
  #     condition     = can(regex("^[a-z]+$", var.umgebung))
  #     error_message = "Nur Kleinbuchstaben."
  #   }
  # OPTIONAL: weitere Eigenschaften einer Variable
  #   nullable  = false
  #   sensitive = true
}
# OPTIONAL: Wert von aussen setzen, Rangfolge von niedrig nach hoch:
#   default < terraform.tfvars < *.auto.tfvars < -var-file < -var < TF_VAR_umgebung
#   export TF_VAR_umgebung=test
#   terraform plan -var 'umgebung=prod'
#   terraform plan -var-file=prod.tfvars     # Datei mit:  umgebung = "prod"

# Diese Variable ist eine Map von Objekten: Schluessel = Servername, Wert = Objekt mit festen
# Feldern. Der Typ object({ ... }) legt fest, welche Felder es gibt und welchen Typ sie haben.
# Daraus baut for_each in main.tf die Ressourcen.
variable "server" {
  description = "Server mit Rolle und SSH-Port"
  # TODO: type = map(object({ ... })) mit rolle (string) und port (number)
  # TODO: default mit app1 (Rolle app, Port 2201) und db1 (Rolle db, Port 2202)
}
# OPTIONAL: Attribut mit Standardwert im Objekt (optional())
#   type = map(object({
#     rolle = string
#     port  = optional(number, 22)
#   }))
# OPTIONAL: weitere Typen
#   variable "ports"  { type = list(number) }
#   variable "tags"   { type = map(string) }
#   variable "aktiv"  { type = bool }
#   variable "ids"    { type = set(string) }
