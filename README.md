# Weasel_Vault

A local, git-tracked vault for downloads, scrapes and the finished batches built
from them.

## What this is

A holding area for material gathered for John's projects. Raw downloads and
scrapes go into `dl_wm_outputs/`; the finished, curated work goes into
`archive/`; copies of the JSON/TSV metadata that describe the material go into
`metadata_backup/`.

## Why it exists

Keeping raw downloads separate from finished work means a scrape can be re-run
or discarded without touching the archive. Git tracks the small text files
(notes, metadata, scripts) and ignores the heavy media, so the vault stays
lightweight and reviewable while the raw files stay on disk.

## Layout

- `dl_wm_outputs/` — working area for new downloads and scrapes.
- `archive/` — finished work, one folder per batch.
- `metadata_backup/` — copies of JSON/TSV metadata.
- `README.md`, `.gitignore` — this file and the ignore rules.

## Where finished work goes

Finished batches live under `archive/<batch>/` — one folder per batch, with its
own notes and metadata. Working files stay in `dl_wm_outputs/` until a batch is
finished; only then is it moved into `archive/`.

## Disk check rule

Before starting a download or scrape, check free space on this home disk:

    df -h /home/perl

Stop and clear space if the filesystem is close to full — the media in
`dl_wm_outputs/` is the usual culprit.

## Not here

No remote: this vault is local only. Publishing is John's call.
