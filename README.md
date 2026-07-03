# sol-pathivu (சொல்பதிவு)

**sol-pathivu** ("word record" in Tamil) extracts clean, plain-text
transcripts from **YouTube videos only**, powered by
[`yt-dlp`](https://github.com/yt-dlp/yt-dlp).

Give it a YouTube video URL, get back a readable `.txt` transcript — no video
download, no API keys, no third-party transcript sites.

> **Scope:** this tool works exclusively with YouTube. It relies on
> `yt-dlp`'s YouTube caption extraction and does not support other video
> platforms (Vimeo, podcasts, local files, etc.).

## Features

- Fetches captions directly via `yt-dlp` — no scraping, no API key required
- Prefers manually-written subtitles; falls back to auto-generated captions
- Strips VTT timestamps/markup and collapses duplicate rolling-caption lines
  into a single readable block of text
- Output is named after the video title and stamped with source URL + upload
  date
- Simple `make` interface, or call the script directly

## Requirements

- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp)
- Python 3 (standard library only — no extra dependencies)
- `make` (optional, for the `make transcript` shortcut)

## Installation

```bash
git clone https://github.com/Mohan-Kumar-0018/sol-pathivu.git
cd sol-pathivu
make install   # installs yt-dlp via Homebrew, if not already present
```

## Usage

```bash
make transcript URL="https://www.youtube.com/watch?v=lvxoFm33-vc"
```

Specify a caption language (default `en`):

```bash
make transcript URL="https://www.youtube.com/watch?v=lvxoFm33-vc" CAPTION_LANG=es
```

Or call the script directly, without `make`:

```bash
./scripts/extract_transcript.sh "<youtube-url>" [output-dir] [lang]
```

Other commands:

```bash
make install   # install yt-dlp via Homebrew if missing
make clean     # remove everything in transcripts/
make help      # list available commands
```

## Output

Transcripts are saved to `transcripts/<video-title-slug>.txt`:

```
<Video Title>
Source: <video URL>
Uploaded: YYYY-MM-DD
Transcript extracted via yt-dlp (language: en).

---

<cleaned transcript text>
```

## How it works

1. `scripts/extract_transcript.sh` calls `yt-dlp` to fetch video metadata and
   download the `.vtt` caption file, without downloading the video itself.
2. `scripts/clean_vtt.py` strips VTT timing/formatting tags and collapses the
   duplicate rolling-caption lines that auto-generated captions produce, into
   a single block of plain text.

## Limitations

- **YouTube only.** This tool is not a general-purpose transcript extractor —
  it does not support Vimeo, podcast feeds, local audio/video files, or any
  other source.
- A video needs *some* caption track (manual or auto-generated) — videos
  with captions disabled entirely can't be transcribed this way.
- Auto-generated caption quality depends entirely on YouTube's speech
  recognition. Older or low-audio-quality videos can produce noticeably
  noisier transcripts; this tool cleans up formatting, not transcription
  accuracy.

## Contributing

Issues and pull requests are welcome. Keep changes small and dependency-free
where possible — the goal is a tool you can read end to end in a few minutes.

## License

[MIT](LICENSE)
