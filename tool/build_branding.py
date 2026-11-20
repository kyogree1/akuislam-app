"""Turunkan aset branding dari artwork 2048x2048 -> assets/branding/.

Sekali pakai; hasilnya yang di-commit.
"""

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

SRC = Path("tool/branding/icon_master.png")
OUT = Path("akuislam/assets/branding")
OUT.mkdir(parents=True, exist_ok=True)

GREEN = (0x0C, 0x33, 0x1E)
CREAM = (0xF2, 0xEA, 0xD8)
LIME = (0xC6, 0xE6, 0x23)
OLIVE = np.array((0x32, 0x2F, 0x26))

im = Image.open(SRC).convert("RGB")
arr = np.asarray(im).astype(int)

# 1. Buang corner olive -> transparan, lalu pusatkan badge di kanvas persegi.
olive = np.abs(arr - OLIVE).sum(axis=2) < 42
alpha = np.where(olive, 0, 255).astype(np.uint8)
rgba = Image.fromarray(np.dstack([np.asarray(im), alpha]), "RGBA")
badge = rgba.crop(rgba.getbbox())
side = max(badge.size)
app_icon = Image.new("RGBA", (side, side), (0, 0, 0, 0))
app_icon.paste(
    badge, ((side - badge.width) // 2, (side - badge.height) // 2), badge
)
app_icon = app_icon.resize((1024, 1024), Image.LANCZOS)
app_icon.save(OUT / "app_icon.png")

# 2. Logo in-app 256 px.
app_icon.resize((256, 256), Image.LANCZOS).save(OUT / "app_logo.png")

# 3. Ikon Play Store 512 px (Play menambah rounded corner sendiri).
app_icon.resize((512, 512), Image.LANCZOS).save(OUT / "play_store_icon.png")

# 4. Foreground adaptive: badge utuh di dalam safe zone 62%, sisanya transparan.
fg_canvas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
scaled = app_icon.resize((636, 636), Image.LANCZOS)
fg_canvas.paste(scaled, ((1024 - 636) // 2, (1024 - 636) // 2), scaled)
fg_canvas.save(OUT / "app_icon_foreground.png")

# 5. Feature graphic Play 1024x500.
fg = Image.new("RGB", (1024, 500), GREEN)
d = ImageDraw.Draw(fg)
badge340 = app_icon.resize((320, 320), Image.LANCZOS)
fg.paste(badge340, (70, 90), badge340)
font_big = ImageFont.truetype(
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 86
)
font_small = ImageFont.truetype(
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 30
)
d.text((440, 168), "AkuIslam", font=font_big, fill=CREAM)
d.rectangle((444, 282, 444 + 120, 288), fill=LIME)
d.text(
    (444, 312),
    "Al-Qur'an offline\nBookmark & riwayat baca",
    font=font_small,
    fill=CREAM,
    spacing=10,
)
fg.save(OUT / "feature_graphic.png")

for f in sorted(OUT.iterdir()):
    print(f"{f.name}: {f.stat().st_size/1024:.0f} KB")
