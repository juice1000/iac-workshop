variable "name" {
  description = "Container- und Hostname"
  type        = string
}

variable "image_id" {
  description = "ID des Images aus docker_image"
  type        = string
}

variable "network_name" {
  type = string
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

variable "weitere_ports" {
  description = "Zusaetzlich veroeffentlichte Ports (intern -> extern)"
  type = list(object({
    intern = number
    extern = number
  }))
  default = []
}
