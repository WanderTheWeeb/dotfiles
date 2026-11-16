#!/usr/bin/env bash
# Tablero de salidas: DEP 03:14  SÁB 15 NOV  ON TIME
t=$(date +%H:%M)
d=$(LC_TIME=es_MX.UTF-8 date +"%a %-d %b" | tr -d '.' | tr '[:lower:]' '[:upper:]' | sed 's/Á/Á/')
full=$(LC_TIME=es_MX.UTF-8 date +"%A %-d de %B %Y")
printf '{"text":"<span size=\\"7pt\\" foreground=\\"#aab4f2\\" letter_spacing=\\"2400\\">DEP</span>  <span font_family=\\"Anton\\" size=\\"15pt\\" letter_spacing=\\"1800\\">%s</span>  <span letter_spacing=\\"1000\\">%s</span>  <span size=\\"7pt\\" foreground=\\"#7fd6a8\\" letter_spacing=\\"2000\\"> ON TIME </span>","tooltip":"%s"}\n' "$t" "$d" "$full"
