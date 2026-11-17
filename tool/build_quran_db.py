import json
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "frontend"
SRC = ROOT / "assets" / "quran"
OUT = ROOT / "assets" / "quran.db"

meta = json.loads((SRC / "surat.json").read_text(encoding="utf-8"))["data"]

if OUT.exists():
    OUT.unlink()
con = sqlite3.connect(OUT)
cur = con.cursor()
cur.execute(
    "CREATE TABLE surahs(nomor INTEGER PRIMARY KEY, namaLatin TEXT, jumlahAyat INTEGER, tempatTurun TEXT, arti TEXT)"
)
cur.execute(
    "CREATE TABLE ayat(surah INTEGER NOT NULL, nomor INTEGER NOT NULL, arab TEXT NOT NULL, indo TEXT NOT NULL, PRIMARY KEY(surah, nomor))"
)
cur.execute("CREATE INDEX idx_ayat_surah ON ayat(surah, nomor)")

for s in meta:
    cur.execute(
        "INSERT INTO surahs VALUES(?,?,?,?,?)",
        (s["nomor"], s["namaLatin"], s["jumlahAyat"], s["tempatTurun"], s["arti"]),
    )
    data = json.loads((SRC / "ayat" / f"{s['nomor']}.json").read_text(encoding="utf-8"))
    for a in data["data"]["ayat"]:
        cur.execute(
            "INSERT OR REPLACE INTO ayat VALUES(?,?,?,?)",
            (s["nomor"], a["nomorAyat"], a["teksArab"], a["teksIndonesia"]),
        )

con.commit()
surahs = cur.execute("SELECT COUNT(*) FROM surahs").fetchone()[0]
ayat = cur.execute("SELECT COUNT(*) FROM ayat").fetchone()[0]
con.close()
print(f"surahs={surahs} ayat={ayat} size={OUT.stat().st_size/1e6:.1f}MB")
