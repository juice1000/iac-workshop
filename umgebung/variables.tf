# Die Server der Uebungsumgebung: Name, SSH-Port auf dem Rechner und feste IP im Netz.
# Wer mehr oder weniger Server will, aendert nur diese Variable (siehe README).
variable "server" {
  type = map(object({
    ssh_port = number
    ip       = string
  }))
  default = {
    server1 = { ssh_port = 2211, ip = "172.31.0.11" }
    server2 = { ssh_port = 2212, ip = "172.31.0.12" }
  }
}
