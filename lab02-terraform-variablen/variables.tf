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
}

# Diese Variable ist eine Map von Objekten: Schluessel = Servername, Wert = Objekt mit festen
# Feldern. Der Typ object({ ... }) legt fest, welche Felder es gibt und welchen Typ sie haben.
# Daraus baut for_each in main.tf die Ressourcen.
variable "server" {
  description = "Server mit Rolle und SSH-Port"
  # TODO: type = map(object({ ... })) mit rolle (string) und port (number)
  # TODO: default mit app1 (Rolle app, Port 2201) und db1 (Rolle db, Port 2202)
}
