# Third-party material

`tools/generate.sh` copies these files out of the pinned adi2 crate at build
time. None of them is stored in this repository; they land in `build/assets/`
(compiled into the binary) and `share/adi2_demo/` (read beside it). Terms as
recorded in adi2's `examples/assets/NOTICE.md` and `REUSE.toml`:

| File | Source | Licence |
|------|--------|---------|
| `icons.svg` | Google Material Icons, path data verbatim | Apache-2.0 |
| `tiger.svg` | "Tiger Face" by microugly, openclipart.org, ear clip paths baked into geometry by adi2 | Public domain (CC-PDDC) |
| `animhorse.gif` | By Janke, 2005, Wikimedia Commons, unmodified | CC BY-SA 2.5 |
| `happycat.png` | adi2 repository | Apache-2.0 |
| `OpenSans-*.ttf` | Open Sans, via adi2's `vendor/open-sans/` | SIL Open Font License 1.1 (`share/adi2_demo/fonts/OFL.txt`) |
| `noto_*.json` | Animated Noto Emoji, Google LLC, unmodified | CC BY 4.0 |

Animated Noto Emoji: <https://googlefonts.github.io/noto-emoji-animation/>.
CC BY 4.0 requires this attribution to travel with the files.

Everything else — `assets/glyphs.svg`, `assets/document.html`,
`assets/document.css`, the stylesheets, layouts, translations and Ada
sources — is original to this repository.

adi2 itself is Apache-2.0 and links vendored MIT, FTL, MPL-2.0 and
BSD-3-Clause code into the binary; see its `README.md` and `REUSE.toml`.
