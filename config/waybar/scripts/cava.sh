#!/usr/bin/env bash
# CODE4U · visualizador de audio para waybar (cava en modo raw ascii -> ▁▂▃▄▅▆▇█)
# Se esconde solo cuando no suena nada; si cava no está instalado, no hace nada.
command -v cava >/dev/null || exit 0
bars=${1:-12}
conf=$(mktemp -t code4u-cava.XXXXXX)
trap 'rm -f "$conf"; kill 0' EXIT
cat > "$conf" <<CONF
[general]
bars = $bars
framerate = 30
sleep_timer = 2
[input]
method = pipewire
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
bar_delimiter = 59
frame_delimiter = 10
CONF
chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
quiet=0
cava -p "$conf" 2>/dev/null | while IFS= read -r line; do
  line=${line%;}
  if [[ $line =~ ^(0;)*0$ ]]; then
    # silencio: imprime vacío una sola vez (waybar esconde el módulo)
    (( quiet )) || { echo '{"text":"","class":"idle"}'; quiet=1; }
    continue
  fi
  quiet=0; out=""
  IFS=';' read -ra v <<< "$line"
  for n in "${v[@]}"; do out+=${chars[$n]}; done
  printf '{"text":"%s","class":"playing"}\n' "$out"
done
