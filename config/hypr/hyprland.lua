-- ╔══════════════════════════════════════════════════════════╗
-- ║  CODE4U · terminal de camiones nocturna              ║
-- ║  Hyprland 0.57 · config Lua                              ║
-- ║  Respaldo del original: ~/.config/code4u-backup-*/    ║
-- ╚══════════════════════════════════════════════════════════╝

-- Paleta (mismos hex en waybar, kitty, fuzzel, mako, hyprlock)
local C = {
    bg     = "0d0f24", pane  = "12153a", raise = "1b1f4a",
    line   = "6b79d6", dim   = "aab4f2", fg    = "f2ead8",
    accent = "e33a8e", neon  = "ff7cbd", warn  = "d8323c",
}
local function rgba(hex, a) return "rgba(" .. hex .. (a or "ff") .. ")" end

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,      -- nativo (1.5 y 1.25 se veían gigantes)
})

---------------------
---- MY PROGRAMS ----
---------------------
local sfx         = "~/.config/code4u/sfx/play"
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "fuzzel"
local browser     = "firefox"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    -- greetd entra solo (autologin): la sesión arranca bloqueada con el boarding pass
    hl.exec_cmd("pidof hyprlock || hyprlock --immediate-render --no-fade-in")
    hl.exec_cmd("~/.config/code4u/wall/start")   -- fondo animado (mpvpaper) o estático (hyprpaper)
    hl.exec_cmd("waybar")
    hl.exec_cmd("command -v swaync >/dev/null && swaync || mako")   -- avisos tipo boleto
    hl.exec_cmd("hypridle")
    hl.exec_cmd("udiskie --automount --notify --tray")   -- monta USBs solito
    hl.exec_cmd("~/.config/code4u/sfx/usbwatch")
    hl.exec_cmd("command -v cliphist >/dev/null && wl-paste --type text --watch cliphist store")
    hl.exec_cmd("command -v cliphist >/dev/null && wl-paste --type image --watch cliphist store")
    hl.exec_cmd("sleep 1.5 && " .. sfx .. " depart")     -- salida del andén
end)

-- Sonidos ligados a eventos
hl.on("workspace.active", function() hl.exec_cmd(sfx .. " ws") end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_THEME", "code4u")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "code4u")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GTK_THEME", "adw-gtk3-dark")
hl.env("ADW_DEBUG_COLOR_SCHEME", "prefer-dark")   -- libadwaita en oscuro sin portal

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 10,
        border_size = 2,
        col = {
            active_border   = { colors = { rgba(C.accent, "ee"), rgba(C.neon, "ee") }, angle = 45 },
            inactive_border = rgba(C.line, "59"),
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding = 0,            -- señalética, no tarjetas
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled        = true,
            range          = 18,
            render_power   = 3,
            color          = rgba(C.accent, "33"),
            color_inactive = "rgba(00000000)",
        },

        blur = { enabled = false }, -- sin blur: transparencia limpia sobre el mapa
    },

    animations = { enabled = true },
})

-- Curva "board": arranca rápido y frena suave, como el camión entrando al andén
hl.curve("board",  { type = "bezier", points = { {0.2, 0.8},  {0.25, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0},      {1, 1}    } })

hl.animation({ leaf = "global",     enabled = true, speed = 8,   bezier = "board" })
hl.animation({ leaf = "border",     enabled = true, speed = 5,   bezier = "board" })
hl.animation({ leaf = "windows",    enabled = true, speed = 5,   bezier = "board", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3,   bezier = "board", style = "slide" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3,   bezier = "board" })
hl.animation({ leaf = "layers",     enabled = true, speed = 4,   bezier = "board", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4,   bezier = "board", style = "slide" })
hl.animation({ leaf = "borderangle",enabled = true, speed = 100, bezier = "linear", style = "loop" })

hl.config({
    dwindle = { preserve_split = true },
    master  = { new_status = "master" },
})

----------------
----  MISC  ----
----------------
hl.config({
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        focus_on_activate        = true,
    },
    layers = {
        allow_new_top_layers_over_existing_fullscreen = true,
    },
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "latam",
        kb_options   = "",
        repeat_delay = 250,   -- ms antes de empezar a repetir (default 600, se sentía lento)
        repeat_rate  = 40,    -- repeticiones por segundo (default 25)
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())   -- cerrar ventana
hl.bind(mainMod .. " + C",      hl.dsp.window.close())
hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("kitty -e zellij attach -c code4u"))   -- terminal con zellij
hl.bind(mainMod .. " + M",      hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd("~/.config/code4u/clip"))          -- historial del portapapeles
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))  -- ventana flotante
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd(sfx .. " launch & " .. menu))     -- pantalla de andenes
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd("pidof hyprlock || (" .. sfx .. " lock & hyprlock)")) -- boleto

-- SUPER solo (soltar) = launcher rofi (Ctrl+Tab cambia a ARCHIVOS / VENTANAS)
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("pkill -x rofi || (" .. sfx .. " launch & rofi -show drun)"), { release = true })
-- SUPER+SHIFT+M = silenciar/activar efectos de sonido
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("~/.config/code4u/sfx/toggle"))
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("pkill waybar; waybar"))
hl.bind(mainMod .. " + N",      hl.dsp.exec_cmd("swaync-client -t -sw"))   -- centro de avisos
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -d -sw"))  -- no molestar

-- Capturas (~/.config/code4u/shot): guardan en ~/Imágenes/Capturas + portapapeles
hl.bind("Print",                     hl.dsp.exec_cmd("~/.config/code4u/shot region"))
hl.bind("SHIFT + Print",             hl.dsp.exec_cmd("~/.config/code4u/shot screen"))
hl.bind("ALT + Print",               hl.dsp.exec_cmd("~/.config/code4u/shot window"))
hl.bind(mainMod .. " + SHIFT + S",   hl.dsp.exec_cmd("~/.config/code4u/shot region"))   -- como en Windows
hl.bind(mainMod .. " + SHIFT + W",   hl.dsp.exec_cmd("~/.config/code4u/shot window"))
hl.bind(mainMod .. " + SHIFT + A",   hl.dsp.exec_cmd("~/.config/code4u/shot edit"))     -- capturar y anotar

-- Foco con flechas
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Paradas (workspaces) 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + ALT + S",   hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Teclas multimedia
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/code4u/osd vol up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/code4u/osd vol down"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("~/.config/code4u/osd vol mute"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("~/.config/code4u/osd mic mute"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/.config/code4u/osd bri up"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/code4u/osd bri down"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Ventanitas utilitarias flotando al centro
hl.window_rule({
    name  = "float-utils",
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|nm-connection-editor|blueman-manager)$" },
    float = true,
    center = true,
    size  = "900 560",
})

-- Capas: launcher y notifs entran deslizando, como letrero de andén
hl.layer_rule({ name = "nl-launcher", match = { namespace = "^launcher$" },      animation = "popin 92%", dim_around = true })
hl.layer_rule({ name = "nl-notifs",   match = { namespace = "^notifications$" }, animation = "slide right" })
hl.layer_rule({ name = "nl-swaync",   match = { namespace = "^swaync-control-center$" }, animation = "slide right" })
hl.layer_rule({ name = "nl-bar",      match = { namespace = "^waybar$" },        animation = "slide top" })

-- Discord (Vesktop) vive en la parada 03 · CHAT
hl.window_rule({
    name  = "vesktop-chat",
    match = { class = "^(vesktop|discord)$" },
    workspace = "3 silent",
})

-- Thunar translúcido como kitty / Vesktop (GTK3 no respeta rgba en CSS)
hl.window_rule({
    name    = "thunar-glass",
    match   = { class = "^([Tt]hunar)$" },
    opacity = "0.72 0.65",
})

-- Spotify translúcido como Thunar (CEF no deja fondo rgba: opacidad de ventana)
hl.window_rule({
    name    = "spotify-glass",
    match   = { class = "^([Ss]potify)$" },
    opacity = "0.75 0.68",
})

-- Discord: además del vidrio del CSS, un extra de transparencia de ventana
hl.window_rule({
    name    = "vesktop-glass",
    match   = { class = "^(vesktop|discord)$" },
    opacity = "0.85 0.78",
})
