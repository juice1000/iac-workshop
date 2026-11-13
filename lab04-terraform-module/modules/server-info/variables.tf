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
}

variable "prefix" {
  type = string
}

variable "ausgabe_ordner" {
  description = "Ordner, in den die Datei geschrieben wird"
  type        = string
}
