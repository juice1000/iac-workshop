# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.

# Die Variablen sind die Eingabe-Schnittstelle des Moduls. Ohne default sind sie Pflicht:
# Der Aufrufer muss sie setzen, sonst bricht terraform plan ab.
# TODO: Variablen name, rolle, prefix (string), port (number)
# TODO: Variable ausgabe_ordner (string) mit description

# OPTIONAL: Eingabe frueh pruefen (in den variable-Block schreiben)
#   validation {
#     condition     = var.port >= 1024 && var.port <= 65535
#     error_message = "Der Port muss zwischen 1024 und 65535 liegen."
#   }
# OPTIONAL: Standardwert machen die Variable optional, ohne Default ist sie Pflicht
#   default = "app"
