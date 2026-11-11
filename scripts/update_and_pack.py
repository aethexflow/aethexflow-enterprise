#!/usr/bin/env python3
"""
AethexFlow Enterprise — Updateable First Launch Packer
Run this anytime you change files. It rebuilds the release ZIP cleanly.
"""

import os
import zipfile
import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT.parent
VERSION = "0.1.5"
ZIP_NAME = f"AETHEXFLOW_ENTERPRISE_FIRST_LAUNCH_v{VERSION}.zip"

EXCLUDE = {
    ".git", "__pycache__", ".DS_Store", "node_modules",
    ".env", "*.pyc", ".wrangler"
}

def should_exclude(path: Path) -> bool:
    parts = set(path.parts)
    if parts & EXCLUDE:
        return True
    if path.name.startswith(".") and path.name not in {".env.example", ".assetsignore"}:
        return True
    return False

def main():
    out = OUT_DIR / ZIP_NAME
    print(f"Packing {ROOT.name} → {out.name}")
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in ROOT.rglob("*"):
            if not p.is_file():
                continue
            if should_exclude(p):
                continue
            arc = Path(ROOT.name) / p.relative_to(ROOT)
            zf.write(p, arc.as_posix())
            print("  +", arc)
    print(f"Done → {out} ({out.stat().st_size // 1024} KB)")

if __name__ == "__main__":
    main()
