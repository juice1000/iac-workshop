# GELOESTE VERSION von practice: alle TODOs sind ausgefuellt, die optionalen Beispiele sind aktiv.
# Beispiele mit [NICHT AKTIV] bleiben bewusst auskommentiert, der Grund steht dabei.
# Optional in dieser Datei: description, sensitive, weiterer Output.
# Der Output ist die Ausgabe-Schnittstelle des Moduls. Nur was hier steht, sieht der Aufrufer.
output "datei" {
  value       = local_file.info.filename
  description = "Pfad der erzeugten Datei"
  sensitive   = false
}
# OPTIONAL: weitere Eigenschaften eines Outputs (in den Block schreiben)
# Aktiv: description und sensitive stehen oben im Output.
# OPTIONAL: weiterer Output
output "inhalt" {
  value = local_file.info.content
}
# Outputs sind die einzige Schnittstelle nach aussen. Interne Ressourcen sieht der Aufrufer nicht.
