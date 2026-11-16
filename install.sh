#!/usr/bin/env bash
# ╔══════════════════════════════════════════╗
# ║  CODE4U dots · instalador                ║
# ╚══════════════════════════════════════════╝
# Uso:
#   ./install.sh              → enlaza configs, fuentes, plugin de zellij y tema GTK
#   ./install.sh --packages   → además instala paquetes (pacman + AUR con yay)
#   ./install.sh --system     → además copia greetd y prende servicios (pide sudo)
#   ./install.sh --all        → todo lo anterior
# Lo que ya exista se respalda como <nombre>.pre-code4u-<fecha> antes de enlazar.
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
PKGS=0; SYS=0
for a in "$@"; do
  case "$a" in
    --packages) PKGS=1 ;;
    --system)   SYS=1 ;;
    --all)      PKGS=1; SYS=1 ;;
    -h|--help)  sed -n 2,10p "$0"; exit 0 ;;
    *) echo "opción desconocida: $a"; exit 1 ;;
  esac
done

say(){ printf '\033[1;35m▸\033[0m %s\n' "$*"; }

link(){ # link <origen en el repo> <destino>
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.pre-code4u-$STAMP"; echo "   respaldo: $dst.pre-code4u-$STAMP"
  fi
  ln -s "$src" "$dst"; echo "   $dst → $src"
}

if [ $PKGS = 1 ]; then
  say "Paquetes (pacman + AUR)"
  command -v yay >/dev/null || { echo "Falta yay: https://github.com/Jguer/yay"; exit 1; }
  yay -S --needed - < "$DOTS/packages/pacman.txt"
  yay -S --needed - < "$DOTS/packages/aur.txt"
fi

say "Configs en ~/.config"
for d in "$DOTS"/config/*; do
  name="$(basename "$d")"
  case "$name" in
    gtk-3.0|gtk-4.0|vesktop)   # sólo archivos sueltos: esas carpetas también guardan cosas de la app
      for f in $(cd "$d" && find . -type f); do link "$d/${f#./}" "$HOME/.config/$name/${f#./}"; done ;;
    *) link "$d" "$HOME/.config/$name" ;;
  esac
done
link "$DOTS/home/.zshrc" "$HOME/.zshrc"

say "Fuentes (Anton, Courier Prime, Martian Mono)"
mkdir -p "$HOME/.local/share/fonts/code4u"
cp -u "$DOTS"/fonts/*.ttf "$HOME/.local/share/fonts/code4u/"
fc-cache -f >/dev/null

say "Plugin de la barra de zellij (zjstatus)"
mkdir -p "$HOME/.config/zellij/plugins"
[ -f "$HOME/.config/zellij/plugins/zjstatus.wasm" ] || \
  curl -sSfL -o "$HOME/.config/zellij/plugins/zjstatus.wasm" \
       https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm

say "Tema GTK, íconos y cursor (code4u = capitaine recoloreado)"
python3 "$DOTS/code4u-tools/make-cursor.py" >/dev/null
python3 "$DOTS/code4u-tools/make-icons.py" >/dev/null
if command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  gsettings set org.gnome.desktop.interface icon-theme Papirus-code4u
  gsettings set org.gnome.desktop.interface cursor-theme code4u
  gsettings set org.gnome.desktop.interface cursor-size 24
  gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10'
  gsettings set org.gnome.desktop.interface monospace-font-name 'MartianMono Nerd Font 10'
fi
mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nInherits=code4u\n' > "$HOME/.icons/default/index.theme"

# el fondo animado viene incluido; si falta, se renderiza (≈3 min)
if [ ! -f "$HOME/.config/hypr/wall/code4u-loop.mp4" ] && command -v uv >/dev/null; then
  say "Renderizando fondo animado"
  (cd "$HOME/.config/code4u/wall" && uv run --with numpy --with pillow python render.py "$HOME/.config/hypr/wall/code4u-loop.mp4")
fi

if [ $SYS = 1 ]; then
  say "Sistema (sudo): greetd, servicios, teclado latam"
  sudo install -m644 "$DOTS/system/greetd/config.toml" /etc/greetd/config.toml
  sudo systemctl enable greetd
  sudo systemctl enable --now fstrim.timer paccache.timer power-profiles-daemon docker
  sudo usermod -aG docker "$USER"
  sudo localectl set-keymap la-latin1
  sudo localectl set-x11-keymap latam
  [ "$(basename "$SHELL")" = zsh ] || chsh -s /usr/bin/zsh
fi

say "Listo. Cierra sesión (o reinicia) para que todo cargue."
