#!/usr/bin/env python3
"""Convert a YouTube .vtt caption file into clean, deduplicated plain text."""

import re
import sys


def clean_vtt(raw: str) -> str:
    lines_out = []
    last = None

    for line in raw.split("\n"):
        line = line.strip()

        if not line:
            continue
        if line.startswith(("WEBVTT", "Kind:", "Language:", "NOTE", "STYLE", "::cue")):
            continue
        if "-->" in line:
            continue
        if re.match(r"^\d+$", line):
            continue

        # strip inline timestamp tags (<00:00:01.234>) and formatting tags (<c>, </c>)
        line = re.sub(r"<[^>]+>", "", line).strip()
        if not line:
            continue

        # auto-generated captions repeat the previous cue's text as rolling
        # context; only collapse *consecutive* duplicates, not all repeats
        if line == last:
            continue

        lines_out.append(line)
        last = line

    return " ".join(lines_out)


def main() -> None:
    if len(sys.argv) < 2:
        print("usage: clean_vtt.py <input.vtt> [output.txt]", file=sys.stderr)
        sys.exit(1)

    in_path = sys.argv[1]
    with open(in_path, encoding="utf-8") as f:
        raw = f.read()

    text = clean_vtt(raw)

    if len(sys.argv) >= 3:
        with open(sys.argv[2], "w", encoding="utf-8") as f:
            f.write(text)
    else:
        print(text)


if __name__ == "__main__":
    main()
