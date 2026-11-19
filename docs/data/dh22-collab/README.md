# DH22 collab — data behind the page

Snapshot 2026-11-19. Metadata only: no captions or raw captures are published here.

## Files

- `accounts.tsv` — the 28-set: account, posts captured, depth, sha256 of the capture (first 12).
- `nodes_28.tsv` — same set with partners and shared posts restricted to the set.
- `edges_28.tsv` — co-post edges where **both** ends are in the 28-set.
- `queue.txt` — the 28 seed accounts. sha256 `6a483b3da6a920bd328f01f7b523c7c0ef68194e3bc30172b2e66d815aabb521`.
- `capped.txt` — the 15 seeds that hit the scroll cap; the list for a deep pass.

All files are covered by `SHA256SUMS`.

## How it was made

`dl_wm`'s `collabnet` walked the 28 seeds one account at a time, storing per-post
metadata (shortcode, taken_at, caption prefix, carousel count, collaborators) and a
word sort. `edges_28.tsv` is the subset of the run's co-post graph whose two
endpoints are both seeds; `shared_posts` is the number of captured posts that list
both accounts as collaborators.

Pacing: the per-scroll pause is the rate limit; the account boundary is a short
jittered pause. Two empty or blocked accounts in a row widen the interval and are
re-queued once; five in a row stop the run. Two depths were used: 50 scroll rounds
(about 600 posts) and 150 rounds (up to 1,800).

## Counts

- seeds 28 · captured 27 · missing 1 (`mareannl`) · posts 27,780
- depth: 14 at 150 rounds · 6 at 50 rounds · 7 complete small feeds
- capped: 15 seeds listed for `--deep`
- edges inside the set: 49

## Limits

- Partial: one seed has no capture; the sweep captures hold about 600 posts each.
- Mixed depths, so edge counts are lower bounds and are not comparable across accounts.
- Live data changes between captures. These files are the snapshot, not the account.
- Membership is a direct co-post with the set (depth one). A partner's partner is
  association and is not in this table.
- The whole-walk graph (1,600 accounts, 1,974 links) is **not** published here; it is
  not the 28-set.
