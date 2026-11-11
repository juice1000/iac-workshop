# Der Output ist die Ausgabe-Schnittstelle des Moduls. Nur was hier steht, sieht der Aufrufer.
output "datei" {
  # TODO: value = Dateiname der Ressource local_file.info
  value = null
}
# OPTIONAL: weitere Eigenschaften eines Outputs (in den Block schreiben)
#   description = "Pfad der erzeugten Datei"
#   sensitive   = false
# OPTIONAL: weiterer Output
#   output "inhalt" {
#     value = local_file.info.content
#   }
# Outputs sind die einzige Schnittstelle nach aussen. Interne Ressourcen sieht der Aufrufer nicht.
