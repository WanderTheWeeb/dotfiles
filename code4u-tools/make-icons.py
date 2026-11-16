#!/usr/bin/env python3
"""CODE4U · tema de íconos 'Papirus-code4u': Papirus-Dark con carpetas magenta.
Sólo copia/recolorea los íconos de carpetas; todo lo demás se hereda de Papirus-Dark."""
import os, re, shutil
SRC = "/usr/share/icons/Papirus-Dark"
DST = os.path.expanduser("~/.local/share/icons/Papirus-code4u")
MAP = {"#5294e2": "#e33a8e", "#4877b1": "#a82468", "#1d344f": "#4a1236", "#e4e4e4": "#f2ead8"}
shutil.rmtree(DST, ignore_errors=True); os.makedirs(DST)
idx = open(os.path.join(SRC, "index.theme")).read()
idx = re.sub(r"^Name=.*$", "Name=Papirus-code4u", idx, count=1, flags=re.M)
idx = re.sub(r"^Inherits=.*$", "Inherits=Papirus-Dark,breeze-dark,hicolor", idx, count=1, flags=re.M)
open(os.path.join(DST, "index.theme"), "w").write(idx)
n = 0
for size in os.listdir(SRC):
    pdir = os.path.join(SRC, size, "places")
    if not os.path.isdir(pdir): continue
    out = os.path.join(DST, size, "places"); os.makedirs(out, exist_ok=True)
    for name in os.listdir(pdir):
        p = os.path.join(pdir, name)
        real = os.path.realpath(p)
        if "folder-blue" not in os.path.basename(real) or not real.endswith(".svg"): continue
        svg = open(real).read()
        for a, b in MAP.items(): svg = re.sub(a, b, svg, flags=re.I)
        open(os.path.join(out, name), "w").write(svg); n += 1
print(f"{n} íconos de carpeta en {DST}")
