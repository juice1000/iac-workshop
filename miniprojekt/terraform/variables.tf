variable "umgebung" {
  type    = string
  default = "schulung"
}

variable "netz" {
  description = "Subnetz fuer App und DB (entspricht einem Projektnetz in OpenStack)"
  type        = string
  default     = "172.30.0.0/24"
}

variable "app_port" {
  description = "Port der Anwendung, auf dem eigenen Rechner unter 127.0.0.1 erreichbar"
  type        = number
  default     = 8080
}
