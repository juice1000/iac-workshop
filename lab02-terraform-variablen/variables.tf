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

  validation {
    condition     = contains(["schulung", "test", "prod"], var.umgebung)
    error_message = "Erlaubt sind: schulung, test, prod."
  }
}

# Diese Variable ist eine Map von Objekten: Schluessel = Servername, Wert = Objekt mit festen
# Feldern. Der Typ object({ ... }) legt fest, welche Felder es gibt und welchen Typ sie haben.
# Daraus baut for_each in main.tf die Ressourcen.
variable "server" {
  description = "Server mit Rolle und SSH-Port"
  type = map(object({
    rolle = string
    port  = number
  }))
  default = {
    app1 = { rolle = "app", port = 2201 }
    db1  = { rolle = "db", port = 2202 }
  }
}
