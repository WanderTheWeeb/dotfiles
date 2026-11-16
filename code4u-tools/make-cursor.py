#!/usr/bin/env python3
"""CODE4U · genera el tema de cursor 'code4u' recoloreando un tema XCursor existente.
cuerpo claro -> magenta #e33a8e, contorno oscuro -> crema #f2ead8 (degradado por luminancia).
uso: python3 make-cursor.py [/usr/share/icons/capitaine-cursors-light] [~/.local/share/icons/code4u]"""
import os, struct, sys, shutil
SRC = sys.argv[1] if len(sys.argv) > 1 else "/usr/share/icons/capitaine-cursors-light"
DST = os.path.expanduser(sys.argv[2] if len(sys.argv) > 2 else "~/.local/share/icons/code4u")
LIGHT = (0xe3, 0x3a, 0x8e)   # cuerpo
DARK  = (0xf2, 0xea, 0xd8)   # contorno
IMG = 0xfffd0002

def recolor(px):
    a = px >> 24
    if not a: return px
    r, g, b = (px >> 16) & 255, (px >> 8) & 255, px & 255
    # premultiplicado: des-premultiplica para medir luminancia
    L = (0.299*r + 0.587*g + 0.114*b) / a
    sat = (max(r, g, b) - min(r, g, b)) / a
    if sat > 0.25: return px  # deja partes ya de color (spinners, etc.)
    L = min(max(L, 0.0), 1.0)
    out = [round((DARK[i] + (LIGHT[i]-DARK[i])*L) * a / 255) for i in range(3)]
    return (a << 24) | (out[0] << 16) | (out[1] << 8) | out[2]

def convert(data):
    magic, hsize, ver, n = struct.unpack_from("<4sIII", data, 0)
    assert magic == b"Xcur"
    data = bytearray(data)
    for i in range(n):
        typ, sub, pos = struct.unpack_from("<III", data, 16 + 12*i)
        if typ != IMG: continue
        _, _, _, _, w, h, _, _, _ = struct.unpack_from("<IIIIIIIII", data, pos)
        off = pos + 36
        pix = struct.unpack_from(f"<{w*h}I", data, off)
        struct.pack_into(f"<{w*h}I", data, off, *map(recolor, pix))
    return bytes(data)

src_c, dst_c = os.path.join(SRC, "cursors"), os.path.join(DST, "cursors")
shutil.rmtree(DST, ignore_errors=True); os.makedirs(dst_c)
for name in sorted(os.listdir(src_c)):
    p = os.path.join(src_c, name)
    if os.path.islink(p): os.symlink(os.readlink(p), os.path.join(dst_c, name)); continue
    with open(p, "rb") as f: d = f.read()
    with open(os.path.join(dst_c, name), "wb") as f: f.write(convert(d))
with open(os.path.join(DST, "index.theme"), "w") as f:
    f.write("[Icon Theme]\nName=code4u\nComment=CODE4U · capitaine en magenta y crema\nInherits=capitaine-cursors-light\n")
print("tema listo en", DST)
