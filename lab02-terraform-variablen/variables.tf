# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.
# GELOESTE VERSION von practice: alle TODOs sind ausgefuellt, die optionalen Beispiele sind aktiv.
# Beispiele mit [NICHT AKTIV] bleiben bewusst auskommentiert, der Grund steht dabei.
# Optional in dieser Datei: zweite validation, nullable und sensitive, tfvars und TF_VAR,
#   optional() im Objekt, weitere Typen.

# BLOCK variable "NAME" { }
# Was: ein Eingabewert fuer das Modul (Zugriff: var.name).
# Wozu: gleicher Code, verschiedene Werte (schulung, test, prod). Eigenschaften:
#   type        erlaubte Form des Werts (string, number, bool, list, map, object ...)
#   default     Vorgabe. Ohne default ist die Variable Pflicht.
#   description Beschreibung fuer Leser und terraform docs
#   validation  eigene Pruefung mit Fehlermeldung, bevor etwas passiert
variable "umgebung" {
  description = "Name der Umgebung, wird als Praefix verwendet"
  type        = string
  default     = "schulung"
  nullable    = false

  validation {
    condition     = contains(["schulung", "test", "prod"], var.umgebung)
    error_message = "Erlaubt sind: schulung, test, prod."
  }

  # OPTIONAL: zweite Pruefung (mehrere validation-Bloecke sind erlaubt)
  validation {
    condition     = can(regex("^[a-z]+$", var.umgebung))
    error_message = "Nur Kleinbuchstaben."
  }
  # OPTIONAL: weitere Eigenschaften einer Variable
  # Aktiv: nullable = false steht oben. sensitive = true wuerde den Wert in allen Ausgaben ausblenden.
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
  type = map(object({
    rolle = string
    port  = optional(number, 22) # Standardwert, wenn der Port fehlt
  }))
  default = {
    app1 = { rolle = "app", port = 2201 }
    db1  = { rolle = "db", port = 2202 }
  }
}
# OPTIONAL: Attribut mit Standardwert im Objekt (optional())
# Aktiv: optional(number, 22) steht oben im Typ.
# OPTIONAL: weitere Typen
variable "ports" {
  type    = list(number)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "aktiv" {
  type    = bool
  default = true
}

variable "ids" {
  type    = set(string)
  default = []
}
