# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.
# GELOESTE VERSION von practice: alle TODOs sind ausgefuellt, die optionalen Beispiele sind aktiv.
# Beispiele mit [NICHT AKTIV] bleiben bewusst auskommentiert, der Grund steht dabei.
# Optional in dieser Datei: validation, default.

# Die Variablen sind die Eingabe-Schnittstelle des Moduls. Ohne default sind sie Pflicht:
# Der Aufrufer muss sie setzen, sonst bricht terraform plan ab.
variable "name" {
  type = string
}

variable "rolle" {
  type = string
}

variable "port" {
  type = number

  validation {
    condition     = var.port >= 1024 && var.port <= 65535
    error_message = "Der Port muss zwischen 1024 und 65535 liegen."
  }
}

variable "prefix" {
  type = string
}
variable "ausgabe_ordner" {
  description = "Ordner, in den die Datei geschrieben wird"
  type        = string
}

# OPTIONAL: Eingabe frueh pruefen (in den variable-Block schreiben)
# Aktiv: die validation steht oben bei der Variable port.
# OPTIONAL: Standardwert machen die Variable optional, ohne Default ist sie Pflicht
# [NICHT AKTIV] Ein default macht die Variable optional. Hier bleiben alle Variablen Pflicht.
#   default = "app"
