"""Unduh data Al-Qur'an dari equran.id untuk membangun assets/quran.db.

Sumber: https://equran.id/api/v2
Output: akuislam/assets/quran/surat.json + akuislam/assets/quran/ayat/{1..114}.json
File JSON mentah tidak di-commit; cukup quran.db hasil build_quran_db.py.
"""

import json
import sys
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "akuislam"
DEST = ROOT / "assets" / "quran"
BASE = "https://equran.id/api/v2"
HEADERS = {"User-Agent": "akumuslim-app/1.0"}
RETRIES = 3


def download(url: str, path: Path, force: bool) -> None:
    if path.exists() and not force:
        try:
            json.loads(path.read_text(encoding="utf-8"))
            return
        except json.JSONDecodeError:
            pass  # file rusak, unduh ulang

    last_error = None
    for attempt in range(1, RETRIES + 1):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=30) as resp:
                payload = resp.read()
            json.loads(payload)  # validasi sebelum simpan
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(payload)
            return
        except Exception as error:  # noqa: BLE001 - jaringan: coba ulang
            last_error = error
            time.sleep(attempt)
    raise RuntimeError(f"gagal {url}: {last_error}")


def main() -> None:
    force = "--force" in sys.argv

    surat_path = DEST / "surat.json"
    download(f"{BASE}/surat", surat_path, force)
    surat = json.loads(surat_path.read_text(encoding="utf-8"))["data"]
    print(f"surat.json: {len(surat)} surah")

    def fetch(surah: dict) -> str:
        nomor = surah["nomor"]
        path = DEST / "ayat" / f"{nomor}.json"
        download(f"{BASE}/surat/{nomor}", path, force)
        detail = json.loads(path.read_text(encoding="utf-8"))["data"]
        return f"{nomor:3d} {surah['namaLatin']}: {len(detail['ayat'])} ayat"

    with ThreadPoolExecutor(max_workers=4) as pool:
        for line in pool.map(fetch, surat):
            print(line)

    print("SELESAI")


if __name__ == "__main__":
    main()
