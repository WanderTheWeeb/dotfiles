#!/usr/bin/env bash
# CODE4U · rice de sistema: plymouth, splash del UKI, paleta del TTY, /etc/issue y greetd
# Uso (en tu kitty):  bash ~/dotfiles/system/rice-system.sh
# Se puede correr varias veces: sólo cambia lo que falte. Respaldos: <archivo>.pre-code4u
set -euo pipefail

c(){ printf '\n\e[35m▌ %s\e[0m\n' "$1"; }
ok(){ printf '   \e[32m✓\e[0m %s\n' "$1"; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS="$(dirname "$HERE")"
BACKUPS=()

backup(){ # respalda el original una sola vez (el primero es el bueno)
  local f="$1"
  if [ -e "$f" ] && [ ! -e "$f.pre-code4u" ]; then
    sudo cp -a "$f" "$f.pre-code4u"; BACKUPS+=("$f.pre-code4u")
  fi
}

# paleta CODE4U para la consola (color0 = fondo noche #0d0f24, resto = kitty)
PARAMS=(
  quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0
  vt.default_red=13,216,127,242,107,227,107,242,42,255,166,255,170,255,159,255
  vt.default_grn=15,50,214,199,121,58,201,234,47,90,236,221,180,124,228,250
  vt.default_blu=36,60,168,107,214,142,214,216,94,98,198,147,242,189,238,240
)

c "PAQUETES (pide tu contraseña)"
sudo pacman -S --needed plymouth cava yazi ffmpegthumbnailer 7zip jq poppler imagemagick git-delta

c "PLYMOUTH · tema code4u"
sudo rm -rf /usr/share/plymouth/themes/code4u
sudo cp -r "$HERE/plymouth/code4u" /usr/share/plymouth/themes/code4u
sudo plymouth-set-default-theme code4u
ok "tema: $(plymouth-set-default-theme)"

c "MKINITCPIO · hook plymouth"
backup /etc/mkinitcpio.conf
if grep -Eq '^HOOKS=\(.*\bplymouth\b' /etc/mkinitcpio.conf; then
  ok "ya estaba"
elif grep -Eq '^HOOKS=\(.*\budev\b' /etc/mkinitcpio.conf; then
  sudo sed -i -E '/^HOOKS=\(/ s/\budev\b/udev plymouth/' /etc/mkinitcpio.conf; ok "plymouth después de udev"
elif grep -Eq '^HOOKS=\(.*\bsystemd\b' /etc/mkinitcpio.conf; then
  sudo sed -i -E '/^HOOKS=\(/ s/\bsystemd\b/systemd plymouth/' /etc/mkinitcpio.conf; ok "plymouth después de systemd"
else
  echo "   no encontré udev ni systemd en HOOKS; agrégalo a mano"; exit 1
fi
grep -E '^HOOKS=' /etc/mkinitcpio.conf

c "KERNEL CMDLINE · quiet splash + colores del TTY"
if ! sudo test -s /etc/kernel/cmdline || ! sudo grep -q 'root=' /etc/kernel/cmdline; then
  # no existía (o venía vacío/sin root=): parte de la línea actual sin BOOT_IMAGE/initrd
  sudo test -e /etc/kernel/cmdline && backup /etc/kernel/cmdline
  tr ' ' '\n' < /proc/cmdline | grep -Ev '^(BOOT_IMAGE|initrd)=|^$' | tr '\n' ' ' | sed 's/ $/\n/' \
    | sudo tee /etc/kernel/cmdline >/dev/null
  ok "creado /etc/kernel/cmdline desde /proc/cmdline"
else
  backup /etc/kernel/cmdline
fi
line="$(sudo cat /etc/kernel/cmdline | tr '\n' ' ' | sed 's/  */ /g;s/ $//')"
for p in "${PARAMS[@]}"; do
  key="${p%%=*}"
  if [[ "$p" == *=* ]]; then
    # quita valor viejo de esa misma llave y pone el nuevo
    line="$(tr ' ' '\n' <<<"$line" | grep -v "^${key//./\\.}=" | tr '\n' ' ' | sed 's/ $//')"
    line="$line $p"
  elif ! tr ' ' '\n' <<<"$line" | grep -qx "$p"; then
    line="$line $p"
  fi
done
printf '%s\n' "$line" | sudo tee /etc/kernel/cmdline >/dev/null
ok "$(sudo cat /etc/kernel/cmdline)"

c "SPLASH del UKI (lo que sale antes de plymouth)"
sudo install -Dm644 "$HERE/splash-code4u.bmp" /usr/share/systemd/bootctl/splash-code4u.bmp
P=/etc/mkinitcpio.d/linux.preset
backup "$P"
if grep -q 'splash-code4u.bmp' "$P"; then
  ok "ya estaba"
elif grep -Eq '^default_options=.*--splash' "$P"; then
  sudo sed -i -E '/^default_options=/ s#--splash [^" ]+#--splash /usr/share/systemd/bootctl/splash-code4u.bmp#' "$P"; ok "splash cambiado"
elif grep -Eq '^default_options=' "$P"; then
  sudo sed -i -E '/^default_options=/ s#"$# --splash /usr/share/systemd/bootctl/splash-code4u.bmp"#' "$P"; ok "splash agregado"
else
  echo 'default_options="--splash /usr/share/systemd/bootctl/splash-code4u.bmp"' | sudo tee -a "$P" >/dev/null; ok "splash agregado"
fi

c "TTY · /etc/issue con el logo"
backup /etc/issue
sudo install -Dm644 "$HERE/issue" /etc/issue
ok "listo"

c "GREETD · tuigreet con el logo"
backup /etc/greetd/config.toml
sudo install -Dm644 "$DOTS/config/code4u/greetd/config.toml" /etc/greetd/config.toml
ok "listo"

c "REGENERANDO UKI (mkinitcpio -P)"
sudo mkinitcpio -P

c "LISTO — reinicia para ver el abordaje 🚌🌹"
if [ ${#BACKUPS[@]} -gt 0 ]; then
  echo "   Respaldos nuevos:"; printf '     %s\n' "${BACKUPS[@]}"
fi
cat <<'EOF'
   Para regresar todo como estaba:
     sudo cp -a /etc/mkinitcpio.conf.pre-code4u /etc/mkinitcpio.conf
     sudo cp -a /etc/kernel/cmdline.pre-code4u /etc/kernel/cmdline   (si no existe, borra /etc/kernel/cmdline)
     sudo cp -a /etc/mkinitcpio.d/linux.preset.pre-code4u /etc/mkinitcpio.d/linux.preset
     sudo cp -a /etc/issue.pre-code4u /etc/issue
     sudo cp -a /etc/greetd/config.toml.pre-code4u /etc/greetd/config.toml
     sudo mkinitcpio -P
EOF
