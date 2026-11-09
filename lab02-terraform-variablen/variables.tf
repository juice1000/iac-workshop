variable "umgebung" {
  description = "Name der Umgebung, wird als Praefix verwendet"
  type        = string
  default     = "schulung"

  validation {
    condition     = contains(["schulung", "test", "prod"], var.umgebung)
    error_message = "Erlaubt sind: schulung, test, prod."
  }
}

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
