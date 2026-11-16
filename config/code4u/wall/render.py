# CODE4U · fondo animado: curvas topográficas que se mecen + neón rosa recorriéndolas.
# Uso:  uv run --with numpy --with pillow python render.py [--preview] [salida.mp4]
# El loop es perfecto (todo es periódico en T), así que el video se repite sin brinco.
import sys, glob, subprocess, numpy as np
from PIL import Image, ImageDraw, ImageFont

W, H, FPS, T = 1920, 1080, 30, 12          # 12 s → 360 frames
N = FPS * T
SEED = 4
BG_EDGE   = np.array([6, 8, 22], np.float32)
BG_CENTER = np.array([13, 15, 40], np.float32)
LINE      = np.array([50, 55, 116], np.float32)
PINK      = np.array([227, 58, 142], np.float32)
PINK_HOT  = np.array([255, 150, 205], np.float32)

rng = np.random.default_rng(SEED)
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)

def noise(scale, seed):
    """Ruido suave (filtrado en frecuencia), media 0, desv 1."""
    r = np.random.default_rng(seed).standard_normal((H, W)).astype(np.float32)
    fy = np.fft.fftfreq(H)[:, None]; fx = np.fft.rfftfreq(W)[None, :]
    k = np.exp(-(fx**2 + fy**2) * (scale**2) * 2 * np.pi**2)
    f = np.fft.irfft2(np.fft.rfft2(r) * k, s=(H, W)).astype(np.float32)
    return (f - f.mean()) / f.std()

F0 = noise(260, SEED) * 1.0 + noise(120, SEED + 1) * 0.25
F1 = noise(200, SEED + 2)
F2 = noise(200, SEED + 3)
K = 5.0            # densidad de curvas
AMP = 0.10         # cuánto se mecen

def grad(f):
    gy, gx = np.gradient(f)
    return gx, gy
G0, G1, G2 = grad(F0), grad(F1), grad(F2)

# fondo con viñeta
r = np.sqrt(((xx - W * .45) / W) ** 2 + ((yy - H * .45) / H) ** 2)
v = np.clip(1 - r * 1.35, 0, 1)[..., None]
BG = BG_EDGE + (BG_CENTER - BG_EDGE) * v

# fase de los pulsos: cada curva tiene dirección y desfase propios
ang = rng.uniform(0, 2 * np.pi, 400).astype(np.float32)
off = rng.uniform(0, 1, 400).astype(np.float32)
lit = (rng.uniform(0, 1, 400) < 0.45)               # ~45% de las curvas llevan neón
spd = rng.choice([1, 1, 2], 400)                    # vueltas por loop (entero → loop perfecto)

def route_overlay():
    """El indicador de ruta de abajo a la derecha (igual al fondo original)."""
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    fonts = glob.glob("/home/wander/.local/share/fonts/**/*ourier*rime*.ttf", recursive=True)
    font = ImageFont.truetype(sorted(fonts)[0], 11) if fonts else ImageFont.load_default()
    txt = " ".join("CODE4U · RUTA 03 · ANDÉN 4")
    tw = d.textlength(txt, font=font)
    d.text((1842 - tw, 982), txt, font=font, fill=(120, 126, 190, 200))
    y = 1010; xs = [1400, 1546, 1692, 1840]
    for i in range(4 * 73):
        x = 1400 + i * (1692 - 1400) / (4 * 73)
        t = i / (4 * 73)
        c = (int(107 + (227 - 107) * t), int(121 + (58 - 121) * t), int(214 + (142 - 214) * t), 220)
        d.line([(x, y), (x + 1.2, y)], fill=c, width=2)
    d.line([(1692, y), (1840, y)], fill=(70, 78, 150, 200), width=2)
    for x in xs[:2]:
        d.ellipse([x - 4, y - 4, x + 4, y + 4], fill=(107, 121, 214, 255))
    d.ellipse([1840 - 5, y - 5, 1840 + 5, y + 5], outline=(107, 121, 214, 255), width=2)
    d.ellipse([1692 - 9, y - 9, 1692 + 9, y + 9], fill=(227, 58, 142, 90))
    d.ellipse([1692 - 6, y - 6, 1692 + 6, y + 6], fill=(255, 92, 170, 255), outline=(255, 190, 220, 255), width=2)
    a = np.asarray(im).astype(np.float32)
    return a[..., :3], a[..., 3:] / 255.0
OV_RGB, OV_A = route_overlay()

def blur_small(img, sigma):
    h, w = img.shape
    fy = np.fft.fftfreq(h)[:, None]; fx = np.fft.rfftfreq(w)[None, :]
    k = np.exp(-(fx**2 + fy**2) * (sigma**2) * 2 * np.pi**2)
    return np.fft.irfft2(np.fft.rfft2(img) * k, s=(h, w))

def frame(i):
    th = 2 * np.pi * i / N
    c, s = np.cos(th) * AMP, np.sin(th) * AMP
    f = F0 + c * F1 + s * F2
    q = f * K
    gx = (G0[0] + c * G1[0] + s * G2[0]) * K
    gy = (G0[1] + c * G1[1] + s * G2[1]) * K
    gm = np.sqrt(gx * gx + gy * gy) + 1e-6
    lvl = np.round(q)
    pd = np.abs(q - lvl) / gm                            # distancia en px a la curva
    line = np.clip(1.6 - pd, 0, 1)                       # ~1.3 px con antialias

    li = (lvl.astype(np.int32) + 200) % 400
    a = ang[li]; o = off[li]; sp = spd[li]
    P = (xx * np.cos(a) + yy * np.sin(a)) / 900.0 + o - sp * (i / N)
    u = P - np.floor(P)
    comet = np.where(u > 0.80, ((u - 0.80) / 0.20) ** 3, 0.0) * lit[li]   # cola → cabeza
    neon_core = line * comet
    wide = np.clip(3.2 - pd, 0, 1) * comet

    small = wide[::4, ::4]
    glow = blur_small(small, 4.0) * 2.2 + blur_small(small, 1.5) * 1.2
    glow = np.asarray(Image.fromarray(glow.astype(np.float32)).resize((W, H), Image.BILINEAR))
    glow = np.clip(glow, 0, 1.5)[..., None]

    img = BG.copy()
    img = img + (LINE - img) * line[..., None] * 0.95
    img = img + PINK * glow * 0.55
    img = img + (PINK_HOT - img) * np.clip(neon_core, 0, 1)[..., None]
    img = img * (1 - OV_A) + OV_RGB * OV_A
    img += rng.uniform(-0.6, 0.6, (H, W, 1)).astype(np.float32)   # dither anti-banding
    return np.clip(img, 0, 255).astype(np.uint8)

if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if "--preview" in sys.argv:
        out = args[0] if args else "preview.png"
        Image.fromarray(frame(int(N * 0.3))).save(out); print(out); sys.exit()
    out = args[0] if args else "code4u-loop.mp4"
    p = subprocess.Popen(["ffmpeg", "-loglevel", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
                          "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-", "-c:v", "libx264", "-preset", "slow",
                          "-crf", "17", "-pix_fmt", "yuv420p", "-movflags", "+faststart", out], stdin=subprocess.PIPE)
    for i in range(N):
        p.stdin.write(frame(i).tobytes())
        if i % 30 == 0: print(f"{i}/{N}", flush=True)
    p.stdin.close(); p.wait(); print("listo", out)
