# dl_wm scraper set

The Instagram scraper/driver code from `roadshowpractice/dl_wm`, copied here so
the vault carries the scripts that produced its data. Upstream is public; this is
a pinned copy, not a fork.

- `bin/collabnet.py` — walk a queue of accounts, scrape each timeline, then draw
  one collab graph. Resumable; Ctrl-C is safe.
- `bin/ig_collab_graph.py` — build the account/co-post graph (png, html, tsv).
- `bin/ig_word_sort.py` — word sorts from captured captions.
- `igp/` — the Playwright profile-history scraper and post model.
- `lib/drive_check.py` — output-drive writability check.

## Running

    python bin/collabnet.py <queue.txt> --max-accounts 40 --cookies <cookies.txt>

Unchanged layout: `bin/` computes the repo root as its parent, so run it from
this directory (or keep `bin/ lib/ igp/` together).

Needs Python 3 with `playwright` (and its Chromium browser); `yt-dlp` is optional
(grid-only posts then get no date).

## Not included

No cookies or credentials. Pass `--cookies` a Netscape-format cookie file of your
own. No queue/input data either — that lives under `inputs/` in the vault.
