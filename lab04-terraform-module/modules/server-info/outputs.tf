# Der Output ist die Ausgabe-Schnittstelle des Moduls. Nur was hier steht, sieht der Aufrufer.
output "datei" {
  value = local_file.info.filename
}
