# Eingaben des Moduls: alles, was sich von Server zu Server unterscheidet. Der Aufrufer (umgebung, Miniprojekt)
# muss sie angeben, nur weitere_ports hat einen Standardwert.
variable "name" {
  description = "Container- und Hostname"
  type        = string
}

variable "image_id" {
  description = "ID des Images aus docker_image"
  type        = string
}

variable "network_name" {
  description = "Name des Docker-Netzes, in das der Server kommt"
  type        = string
}

variable "ipv4_address" {
  description = "Feste IP im Docker-Netz"
  type        = string
}

variable "ssh_port" {
  description = "Port auf dem eigenen Rechner (127.0.0.1), der auf SSH im Container zeigt"
  type        = number
}

variable "public_key" {
  description = "Oeffentlicher SSH-Schluessel fuer root"
  type        = string
}

# Liste von Portpaaren. Der Standard [] heisst: keine zusaetzlichen Ports. Das Modul macht daraus per
# dynamic-Block (main.tf) je einen veroeffentlichten Port.
variable "weitere_ports" {
  description = "Zusaetzlich veroeffentlichte Ports (intern -> extern)"
  type = list(object({
    intern = number
    extern = number
  }))
  default = []
}
