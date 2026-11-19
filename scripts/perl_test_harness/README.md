# Perl test harness

The Perl harness around the `dl_wm` download path, written to prove the pipeline
end to end without depending on a single lucky run.

- `ghost_soldier_test.pl` — one-shot harness: preflight (cookie file exists and is
  mode 0600), then download a known post with `yt-dlp`, then check the output
  (file present, non-zero, SHA256 recorded, report written). TAP-ish `ok`/`not ok`
  lines, exits non-zero on failure. Log: `~/perl_harness/ghost_soldier_run.log`.
- `t/run_all.pl` — runs the `t/` suite in order, resumable, one log per test.
- `t/00_env.t` — the Python/`yt-dlp`/`ffmpeg` tools exist and run.
- `t/10_network.t` — Instagram reachable.
- `t/20_cookie_file.t` — cookie file present, 0600, Netscape format, has a
  sessionid entry.
- `t/30_session.t` — the cookie session resolves a logged-in profile.
- `t/40_download.t` — real download + SHA256 + output checks (the slow one).

Suite status at last run (2026-11-18): 00–30 pass, 40 fails on this box
("No video formats found" for the test post).

## Paths

The scripts expect the agent's layout, which is why they are kept as-is:

    ~/repos/dl_wm                     the dl_wm clone
    ~/micromamba/envs/dl_wm/bin       python, yt-dlp
    ~/dl_wm_outputs/ghost_soldier     output dir
    ~/perl_harness                    run log

Override with `HOME=/some/prefix` if the tree is elsewhere; the individual
paths are still computed from `$HOME`.

## Running

    perl ghost_soldier_test.pl
    perl t/run_all.pl                 # resumable; reruns stay in the same dirs

## Not included

No cookies. Point the cookie path at your own Netscape-format file (the defaults
are the agent's, not secrets). No downloaded media either.
