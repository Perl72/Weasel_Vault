# DH22 collab — project

Status: first pass and mod-one assembly done; deep pass not started.
Last updated: 2026-11-19.

## What this is

A metadata capture of the Instagram collaborator network of the Dark Horse
set — who co-posts with whom — made so the co-post structure can be read and
re-checked from our own files. Metadata only: shortcode, taken_at, caption
(first 200 chars), carousel count, collaborators. No media is downloaded.

## The set

**28 accounts.** This is the Dark Horse multiset. It is not the rigid grid
(113 accounts) and not S16/holland24 (16). Numbers and labels from one set do
not carry into another without a separate check.

```
47contadoallan          4ludlins                _revistatimeline
americatv               biakicis                carlosjordy
cristianosenpolitica    damaresalvesoficial     dignidadyderecho
eduardoverastegui       emilia_maldonadojaramillo freedomcenterlu
generalgirao            gusgayer                herzog_foundation
janethinostrozaok       jorgeseifjunior         laisjordy
lilipacheco.usa         mareannl                mariofriasoficial
momsforamerica          pabloaproano            paolafelixdiaz
rolando_gps             timballard89            timballardfoundationecuador
verosevillaec
```

Membership here means a direct co-post with the group (depth one). A partner's
partner is association, not membership.

## Where the data comes from

- Queue: `inputs/dh22_collab_queue.txt` (28 seeds, one per line).
  sha256 `1f9e4c1ccd1798aec7a4667f8c3b7bfa3aa4e59c734961fc931d19b6e5cd4d7d`.
- Spec: `inputs/2026-11-05_dh22_collab_spec_copy.md` and its input
  `SHA256SUMS`, copied from `/srv/agents/swap/2026-11-16/dh22_collab_input/`
  (verified 3/3 there).
- Tool: `/home/perl/repos/dl_wm` — `bin/collabnet.py` walking accounts and
  `igp/profile_history.py` producing each timeline.
- Captures were made 2026-11-18 and 2026-11-19 under the `haddamgoel` login.

Captured files are the data; web/news/wiki material is context only and never
moves or adds an account.

## Method

One account at a time: scrape the timeline, write the word sort, then move on.
Request rate is held by the per-scroll pause (3–6 s); the account boundary is a
short jittered pause, not a second rate limit. Two empty or blocked accounts in
a row widen the interval automatically, successes walk it back down, and five
in a row stops the run; each such account is re-queued once.

Two depths:

- **sweep** — 50 scroll rounds, about 600 posts per account. Used for the wide
  pass; fast enough that a large queue is not a multi-week job.
- **deep** — 600 rounds. This is the standing “far enough back” cap for
  collaborator work, and it is the pass for accounts that hit the sweep cap.

Snowballed collaborators are written to a separate
`snowball_<queue>.txt` for a later run. They are not appended to the run queue,
so a pass finishes the set it was given.

The graph is drawn once, at the end of a run, over the accounts the run
touched. (The graph from the 11-19 first pass covers the whole old walk, 1,600
accounts, so it is not a 28-set artifact and is not in this module.)

## Layout

```
PROJECT.md              this file
README.md               what the captures are, counts, caveats
SHA256SUMS              over every file here
inputs/                 queue, capped list, spec copy, input SHA256SUMS (read-only)
timelines/              <account>_timeline.jsonl, one JSON record per post
word_sorts/             <account>_word_sort.txt
metadata/inventory.tsv  one row per seed: capture dir, posts, bytes, sha12, status, file
metadata/status.tsv     latest run row per seed
```

## Status

- Seeds: 28. Captured: 27 (27,780 posts, 7.8 MB of JSONL). Missing:
  `mareannl` (0 posts on both attempts, 2026-11-19).
- Depth: 14 accounts at 150 rounds, 6 at the 50-round sweep depth, 7 small
  feeds that ended on their own.
- Capped: 15 seeds listed in `inputs/capped_dh22_collab_queue.txt` for
  `--deep`.
- Parked: 1,336 snowballed accounts in
  `snowball_dh22_collab_queue.txt` (run folder), deliberately not part of this
  module.

## To run it again

```
# wide pass (no snowball), supervised
python bin/collabnet.py <queue> --sweep --max-accounts 0

# deep pass on the capped set
python bin/collabnet.py inputs/capped_dh22_collab_queue.txt --deep

# the parked snowball set, later
python bin/collabnet.py snowball_dh22_collab_queue.txt --sweep --snowball
```

## Rules

- Text only in the repo; screenshots, video and the graph PNG stay on disk.
- Every file here is covered by `SHA256SUMS`; the inventory gives the first 12
  characters per capture.
- Live sites change between captures. When two captures disagree, note it once
  and move on; the captures and hashes are the record.
- Do not mix this set with the rigid grid or S16 when quoting a number.
