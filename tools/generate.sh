#!/usr/bin/env bash
#  Regenerates the Ada sources under src/generated/ from css/, ui/, i18n/
#  and assets/, and stages the third-party assets taken from the pinned
#  adi2 crate. Runs as an Alire pre-build action, which is what sets
#  ADI2_TOOLS; by hand, run it as `alr exec -- tools/generate.sh`.
#
#  Output is written to a scratch directory first and copied over only
#  where it differs, so an unchanged input does not trigger a recompile.
set -euo pipefail

cd "$(dirname "$0")/.."
: "${ADI2_TOOLS:?ADI2_TOOLS is unset: run through alr, e.g. alr exec -- tools/generate.sh}"

readonly OUT=src/generated
readonly STAGE=build/assets
readonly SHARE=share/adi2_demo
readonly UPSTREAM="$ADI2_TOOLS/../examples/assets"
readonly SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

mkdir -p "$OUT" "$STAGE" "$SHARE/lottie" "$SHARE/fonts"

#  copies $1 to $2 unless the two already hold the same bytes
sync_file() {
  cmp -s "$1" "$2" 2>/dev/null || cp "$1" "$2"
}

#  --- third-party assets (licences in NOTICE.md) -------------------------
for f in icons.svg tiger.svg animhorse.gif happycat.png; do
  sync_file "$UPSTREAM/$f" "$STAGE/$f"
done
sync_file "$(readlink -f "$UPSTREAM/OpenSans-Regular.ttf")" "$STAGE/OpenSans-Regular.ttf"
#  rlottie reads animations from files only, and Adi.Font.Register_Variant
#  takes a path, so these stay beside the binary rather than in the bundle
mkdir -p "$SHARE/fonts"
for f in Bold SemiBold Italic BoldItalic; do
  sync_file "$ADI2_TOOLS/../vendor/open-sans/static/OpenSans-$f.ttf" "$SHARE/fonts/OpenSans-$f.ttf"
done
sync_file "$ADI2_TOOLS/../vendor/open-sans/OFL.txt" "$SHARE/fonts/OFL.txt"
for f in noto_party_popper noto_rocket noto_red_heart noto_star noto_fire noto_thumbs_up; do
  sync_file "$UPSTREAM/$f.json" "$SHARE/lottie/$f.json"
done

#  --- stylesheets ---------------------------------------------------------
#  app.css and overlays.css name colours only through var(), which the
#  palettes define, so each is compiled together with a palette. At run
#  time the same pairing is made by installing both sheets as one set.
css() { python3 "$ADI2_TOOLS/css_to_ada.py" "$@" --properties-package=Demo.Properties >/dev/null; }

css css/palette_dark.css  "$SCRATCH/palette_dark_styles.ads"  --package-name=Palette_Dark_Styles
css css/palette_light.css "$SCRATCH/palette_light_styles.ads" --package-name=Palette_Light_Styles

cat css/palette_dark.css css/app.css > "$SCRATCH/app.css"
css "$SCRATCH/app.css" "$SCRATCH/app_styles.ads" --package-name=App_Styles

for theme in dark light; do
  cat "css/palette_$theme.css" css/overlays.css > "$SCRATCH/overlays_$theme.css"
  css "$SCRATCH/overlays_$theme.css" "$SCRATCH/overlay_${theme}_styles.ads" \
      --package-name="Overlay_${theme^}_Styles"
done

#  --- widget trees --------------------------------------------------------
for xml in ui/*.xml; do
  name=$(basename "$xml" .xml)
  [[ $name == widgets_extra ]] && continue
  package=$(python3 -c 'import sys; print("_".join(p.capitalize() for p in sys.argv[1].split("_")) + "_UI")' "$name")
  python3 "$ADI2_TOOLS/xml_to_ada.py" "$xml" --output-dir "$SCRATCH" \
    --package-name "$package" --grammar ui/widgets_extra.xml --i18n >/dev/null
done

#  --- translations and the asset bundle ----------------------------------
python3 "$ADI2_TOOLS/po_to_ada.py" --output-dir "$SCRATCH" \
  --package-name Demo_Translations i18n/*.po >/dev/null

#  the stylesheets travel too, as the fallback when css/ is not beside
#  the binary; keys keep their directory, e.g. "css/app.css"
mkdir -p "$SCRATCH/bundle/css"
cp css/*.css "$SCRATCH/bundle/css/"
cp assets/* "$STAGE"/* "$SCRATCH/bundle/"
python3 "$ADI2_TOOLS/binary_to_ada.py" --output-dir "$SCRATCH" \
  --package-name Demo_Bundle --base-dir "$SCRATCH/bundle" \
  $(find "$SCRATCH/bundle" -type f | sort) >/dev/null

#  --- publish -------------------------------------------------------------
for f in "$SCRATCH"/*.ads "$SCRATCH"/*.adb; do
  sync_file "$f" "$OUT/$(basename "$f")"
done
