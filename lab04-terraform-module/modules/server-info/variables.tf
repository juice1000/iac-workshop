variable "name" {
  type = string
}

# TODO: Variablen rolle (string), port (number), prefix (string)

variable "ausgabe_ordner" {
  description = "Ordner, in den die Datei geschrieben wird"
  type        = string
}

#
# OPTIONAL / GUT ZU WISSEN
# - Eingaben immer mit type und description. Mit validation fruehe, verstaendliche Fehlermeldungen geben.
# - Defaults sparsam setzen: Pflichtvariablen erzwingen, dass der Aufrufer bewusst entscheidet.
