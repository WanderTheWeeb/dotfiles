# Firefox · CODE4U
`chrome/` y `user.js` van enlazados dentro del perfil por defecto:
```sh
P=$(find ~/.config/mozilla/firefox ~/.mozilla/firefox -maxdepth 1 -name '*.default-release' 2>/dev/null | head -1)
ln -sfn ~/dotfiles/firefox/chrome "$P/chrome"; ln -sf ~/dotfiles/firefox/user.js "$P/user.js"
```
Reinicia Firefox para ver los cambios.
