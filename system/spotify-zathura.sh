#!/usr/bin/env bash
# CODE4U · Spotify con Spicetify (tema code4u) + Zathura para PDFs
# Uso (en tu kitty):  bash ~/dotfiles/system/spotify-zathura.sh
# Pide tu contraseña para instalar paquetes y para dar permiso a Spicetify sobre /opt/spotify.
set -euo pipefail
c(){ printf '\n\e[35m▌ %s\e[0m\n' "$1"; }
DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

c "PAQUETES: zathura (repos) + spotify y spicetify (AUR)"
sudo pacman -S --needed zathura zathura-pdf-mupdf
yay -S --needed spotify spicetify-cli

c "ZATHURA → abre los PDFs por defecto"
xdg-mime default org.pwmt.zathura.desktop application/pdf

c "SPOTIFY → primera vez (se abre y se cierra solo para crear su config)"
if [ ! -f "$HOME/.config/spotify/prefs" ]; then
  spotify >/dev/null 2>&1 &
  for _ in $(seq 1 30); do [ -f "$HOME/.config/spotify/prefs" ] && break; sleep 1; done
  sleep 3; pkill -x spotify || true; sleep 1
fi
[ -f "$HOME/.config/spotify/prefs" ] || { echo "No se creó ~/.config/spotify/prefs: abre Spotify una vez a mano y vuelve a correr esto"; exit 1; }

c "SPICETIFY → permisos sobre /opt/spotify (pide contraseña)"
sudo chmod a+wr /opt/spotify
sudo chmod -R a+wr /opt/spotify/Apps

c "SPICETIFY → tema code4u"
spicetify >/dev/null 2>&1 || true   # crea ~/.config/spicetify la primera vez
mkdir -p "$HOME/.config/spicetify/Themes"
ln -sfn "$DOTS/spicetify/Themes/code4u" "$HOME/.config/spicetify/Themes/code4u"
spicetify config current_theme code4u color_scheme code4u inject_css 1 replace_colors 1 overwrite_assets 1
spicetify backup apply || spicetify restore backup apply

c "LISTO — abre Spotify 🚌🎵  (si Spotify se actualiza y pierde el tema: spicetify backup apply)"
