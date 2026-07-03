SHELL := /bin/bash
OUT_DIR := transcripts
CAPTION_LANG ?= en

.PHONY: transcript install clean help

help:
	@echo "make transcript URL=<youtube-url> [CAPTION_LANG=en]  - extract a transcript"
	@echo "make install                                          - install yt-dlp via Homebrew"
	@echo "make clean                                             - remove extracted transcripts"

transcript:
ifndef URL
	$(error Usage: make transcript URL="https://www.youtube.com/watch?v=..." [CAPTION_LANG=en])
endif
	@./scripts/extract_transcript.sh "$(URL)" "$(OUT_DIR)" "$(CAPTION_LANG)"

install:
	@command -v yt-dlp >/dev/null 2>&1 && echo "yt-dlp already installed" || brew install yt-dlp

clean:
	@rm -rf "$(OUT_DIR)"/*
	@echo "cleared $(OUT_DIR)/"
