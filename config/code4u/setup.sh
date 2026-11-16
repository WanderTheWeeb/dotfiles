#!/usr/bin/env bash
# CODE4U · instalación de paquetes + montaje de la USB BACKUP
# Uso (en tu kitty):  bash ~/.config/code4u/setup.sh
set -e
c(){ printf '\n\e[35m▌ %s\e[0m\n' "$1"; }

c "PAQUETES (pide tu contraseña)"
sudo pacman -S --needed \
  rofi udisks2 udiskie gvfs thunar thunar-volman thunar-archive-plugin tumbler file-roller \
  neovim lazygit fastfetch brightnessctl pavucontrol zellij \
  zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions \
  fzf zoxide eza bat starship ripgrep fd unzip nodejs npm tree-sitter-cli

c "SHELL → zsh (pide tu contraseña otra vez)"
[ "$SHELL" = /usr/bin/zsh ] || chsh -s /usr/bin/zsh

c "USB BACKUP → montando"
if ! findmnt -rn -S LABEL=BACKUP >/dev/null; then
  udisksctl mount -b /dev/disk/by-label/BACKUP -o ro || { sudo mkdir -p /mnt/backup && sudo mount -o ro LABEL=BACKUP /mnt/backup; }
fi
findmnt -rn -S LABEL=BACKUP -o TARGET

c "LISTO — avísale a Claude para restaurar el backup 🚌"
