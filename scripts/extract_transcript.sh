#!/usr/bin/env bash
# Extract a clean plain-text transcript from a YouTube video using yt-dlp.
#
# Usage:
#   extract_transcript.sh <youtube-url> [output-dir] [lang]
#
# Prefers human-written subtitles; falls back to auto-generated captions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

URL="${1:-}"
OUT_DIR="${2:-$SCRIPT_DIR/../transcripts}"
LANG="${3:-en}"

if [[ -z "$URL" ]]; then
  echo "usage: $(basename "$0") <youtube-url> [output-dir] [lang]" >&2
  exit 1
fi

if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "error: yt-dlp is not installed. Install it with: brew install yt-dlp" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Fetching video info..." >&2
TITLE="$(yt-dlp --skip-download --print "%(title)s" "$URL")"
VIDEO_ID="$(yt-dlp --skip-download --print "%(id)s" "$URL")"
UPLOAD_DATE="$(yt-dlp --skip-download --print "%(upload_date)s" "$URL" 2>/dev/null || echo "")"

# slugify the title: lowercase, alnum + hyphens only
SLUG="$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
SLUG="${SLUG:0:80}"
if [[ -z "$SLUG" ]]; then
  SLUG="$VIDEO_ID"
fi

echo "Downloading captions ($LANG)..." >&2
yt-dlp \
  --skip-download \
  --write-sub --write-auto-sub \
  --sub-lang "$LANG" \
  --sub-format vtt \
  -o "$TMP_DIR/captions" \
  "$URL" >&2

# prefer a manually-written subtitle file over the auto-generated one
VTT_FILE="$(find "$TMP_DIR" -name "*.$LANG.vtt" ! -name "*auto*" | head -n1)"
if [[ -z "$VTT_FILE" ]]; then
  VTT_FILE="$(find "$TMP_DIR" -name "*.vtt" | head -n1)"
fi

if [[ -z "$VTT_FILE" || ! -f "$VTT_FILE" ]]; then
  echo "error: no captions found for this video in language '$LANG'" >&2
  exit 1
fi

OUT_FILE="$OUT_DIR/$SLUG.txt"

{
  echo "$TITLE"
  echo "Source: $URL"
  if [[ -n "$UPLOAD_DATE" ]]; then
    echo "Uploaded: ${UPLOAD_DATE:0:4}-${UPLOAD_DATE:4:2}-${UPLOAD_DATE:6:2}"
  fi
  echo "Transcript extracted via yt-dlp (language: $LANG)."
  echo
  echo "---"
  echo
  python3 "$SCRIPT_DIR/clean_vtt.py" "$VTT_FILE"
  echo
} > "$OUT_FILE"

echo "Saved transcript to: $OUT_FILE" >&2
echo "$OUT_FILE"
