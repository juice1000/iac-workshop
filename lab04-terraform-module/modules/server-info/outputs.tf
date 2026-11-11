output "datei" {
  # TODO: value = Dateiname der Ressource local_file.info
  value = null
}

#
# OPTIONAL / GUT ZU WISSEN
# - sensitive = true und depends_on sind auch in outputs moeglich.
# - Outputs sind die einzige Schnittstelle nach aussen. Interne Ressourcen sind fuer den Aufrufer unsichtbar.
