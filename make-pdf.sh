#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HTML_INPUT="${1:-"$SCRIPT_DIR/cv.html"}"
PDF_OUTPUT="${2:-"$SCRIPT_DIR/cv.pdf"}"

CANDIDATES=(
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
"/Applications/Chromium.app/Contents/MacOS/Chromium"
"google-chrome"
"chromium"
"chrome"
)

CHROME_BIN=""
for candidate in "${CANDIDATES[@]}"; do
  if command -v "$candidate" >/dev/null 2>&1; then
    CHROME_BIN="$(command -v "$candidate")"
    break
  elif [ -x "$candidate" ]; then
    CHROME_BIN="$candidate"
    break
  fi
done

WKHTMLTOPDF_BIN=""
if command -v wkhtmltopdf >/dev/null 2>&1; then
  WKHTMLTOPDF_BIN="$(command -v wkhtmltopdf)"
fi

if [ -z "$WKHTMLTOPDF_BIN" ] && [ -z "$CHROME_BIN" ]; then
  echo "Error: Neither wkhtmltopdf nor Chrome/Chromium found. Install one of them." >&2
  exit 1
fi

# Normalize to absolute paths
HTML_ABS="$HTML_INPUT"
PDF_ABS="$PDF_OUTPUT"
case "$HTML_ABS" in
  /*) ;;
  *) HTML_ABS="$SCRIPT_DIR/$HTML_ABS" ;;
esac
case "$PDF_ABS" in
  /*) ;;
  *) PDF_ABS="$SCRIPT_DIR/$PDF_ABS" ;;
esac

URL="file://$HTML_ABS"

if [ -n "$WKHTMLTOPDF_BIN" ]; then
  "$WKHTMLTOPDF_BIN" \
    --print-media-type \
    --enable-local-file-access \
    --margin-top 12mm --margin-right 12mm --margin-bottom 12mm --margin-left 12mm \
    "$HTML_ABS" "$PDF_ABS"
  echo "PDF written to: $PDF_ABS (wkhtmltopdf)"
else
  "$CHROME_BIN" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="$PDF_ABS" "$URL"
  echo "PDF written to: $PDF_ABS (Chrome headless)"
fi


