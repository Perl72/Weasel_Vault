#!/usr/bin/perl
use strict;
use warnings;
use File::Path qw(make_path);
use POSIX qw(strftime);

$| = 1;

my $URL    = 'https://www.instagram.com/p/DfnnH-uF5Aj/';
my $HOME   = $ENV{HOME} // '/home/perl';
my $REPO   = "$HOME/repos/dl_wm";
my $COOKIE = "$REPO/conf/instagram.cookies.haddamgoel.txt";
my $PY     = "$HOME/micromamba/envs/dl_wm/bin/python";
my $YTDLP  = "$HOME/micromamba/envs/dl_wm/bin/yt-dlp";
my $OUTDIR = "$HOME/dl_wm_outputs/ghost_soldier";
my $OUTTMPL = '~/dl_wm_outputs/ghost_soldier/%(id)s.%(ext)s';
my $REPORT = "$OUTDIR/report.txt";
my $LOGDIR = "$HOME/perl_harness";
my $RUNLOG = "$LOGDIR/ghost_soldier_run.log";

my $allok = 1;
sub result {
    my ($ok, $name) = @_;
    print(($ok ? 'ok ' : 'not ok ') . $name . "\n");
    $allok = 0 unless $ok;
    return $ok;
}

# ---- 1. Preflight -------------------------------------------------------

# cookie file exists in conf/
my $cookie_exists = (-f $COOKIE) ? 1 : 0;
result($cookie_exists, 'cookie_file_exists');

# cookie file mode 0600
my $mode_ok = 0;
if ($cookie_exists) {
    my $mode = (stat($COOKIE))[2] & 07777;
    $mode_ok = ($mode == 0600) ? 1 : 0;
}
result($mode_ok, 'cookie_mode_0600');

# cookie file git-ignored (same check as A.3)
my $ignored = 0;
my $ign_line = '';
if ($cookie_exists) {
    my $pid = open(my $gh, '-|', 'git', '-C', $REPO,
        'check-ignore', '-v', 'conf/instagram.cookies.haddamgoel.txt');
    if (defined $pid) {
        local $/;
        $ign_line = <$gh> // '';
        close $gh;
        $ignored = ($ign_line =~ /conf\/instagram\.cookies\.haddamgoel\.txt/) ? 1 : 0;
    }
}
result($ignored, 'cookie_git_ignored');

# env python imports yt_dlp
my $py_ok = (system { $PY } $PY, '-c', 'import yt_dlp') == 0 ? 1 : 0;
result($py_ok, 'python_imports_yt_dlp');

# the URL is the only URL in the harness (hard-coded constant)
my $url_only = 0;
if (open(my $sf, '<', $0)) {
    local $/;
    my $src = <$sf> // '';
    close $sf;
    my @urls = ($src =~ m{https?://[^\s"'<>)\]]+}g);
    $url_only = (@urls == 1 && $urls[0] eq $URL) ? 1 : 0;
}
result($url_only, 'single_url');

# ---- 2. One download ----------------------------------------------------

my $exit_str = 'skipped';
my $did_run  = 0;

if ($cookie_exists && $mode_ok && $ignored && $py_ok && $url_only) {
    make_path($OUTDIR) unless -d $OUTDIR;
    open(my $lf, '>', $RUNLOG) or die "cannot open run log $RUNLOG: $!";
    close $lf;

    my @args = ($YTDLP, '--cookies', $COOKIE, '-o', $OUTTMPL, $URL);

    open(my $oldout, '>&', \*STDOUT) or die "dup STDOUT: $!";
    open(my $olderr, '>&', \*STDERR) or die "dup STDERR: $!";
    open(STDOUT, '>', $RUNLOG) or die "redirect STDOUT: $!";
    open(STDERR, '>&', \*STDOUT) or die "redirect STDERR: $!";

    system { $YTDLP } @args;

    my $st = $?;
    open(STDOUT, '>&', $oldout) or warn "restore STDOUT: $!";
    open(STDERR, '>&', $olderr) or warn "restore STDERR: $!";

    $did_run = 1;
    if ($st == -1) {
        $exit_str = 'exec_failed';
    } elsif ($st & 127) {
        $exit_str = 'signal ' . ($st & 127);
    } else {
        $exit_str = ($st >> 8) . '';
    }
}

# ---- 3. Assertions and report ------------------------------------------

my $exit_ok = ($did_run && $exit_str eq '0') ? 1 : 0;
result($exit_ok, 'download_exit_0');

# login-page / not-logged-in detection
my $login_hit = '';
if ($did_run && -f $RUNLOG && open(my $rf, '<', $RUNLOG)) {
    local $/;
    my $log = <$rf> // '';
    close $rf;
    my @pat = (
        qr/not\s+logged\s+in/i,
        qr/logged?\s+in\s+required/i,
        qr/login\s+required/i,
        qr/(redirect(?:ed|ing|s)?)\b.{0,40}\blogin/i,
        qr/login\s+page/i,
        qr/please\s+(?:log|sign)\s+in/i,
        qr{accounts/login}i,
        qr/checkpoint(?:\.ig)?/i,
        qr/challenge_required/i,
        qr/sign\s+in\s+to\s+(?:confirm|view|continue)/i,
    );
    for my $p (@pat) {
        if ($log =~ $p) { $login_hit = "$p"; last; }
    }
}
result($login_hit eq '' ? 1 : 0, 'download_no_login');

# find a non-empty output file (exclude the report and partial files)
my ($fname, $fsize, $sha) = ('N/A', 'N/A', 'N/A');
my $best;
if (-d $OUTDIR && opendir(my $dh, $OUTDIR)) {
    while (my $e = readdir($dh)) {
        next if $e eq '.' || $e eq '..';
        next if $e eq 'report.txt';
        next if $e =~ /\.(?:part|ytdl|temp)$/i;
        my $p = "$OUTDIR/$e";
        next unless -f $p;
        my $sz = -s $p;
        next unless defined $sz && $sz > 0;
        $best = [$p, $e, $sz] if !defined $best || $sz > $best->[2];
    }
    closedir($dh);
}
my $file_ok = defined $best ? 1 : 0;
result($file_ok, 'output_file_nonempty');

if ($file_ok) {
    ($fname, $fsize) = ($best->[1], $best->[2]);
    my $pid = open(my $sh, '-|', 'sha256sum', $best->[0]);
    if (defined $pid) {
        my $line = <$sh> // '';
        close $sh;
        $sha = (split(/\s+/, $line))[0] // 'N/A';
    }
}

my $date = strftime('%Y-%m-%d %H:%M:%S', localtime);

if (make_path($OUTDIR) || -d $OUTDIR) {
    if (open(my $rf, '>', $REPORT)) {
        print $rf "URL: $URL\n";
        print $rf "date: $date\n";
        print $rf "exit_code: $exit_str\n";
        print $rf "filename: $fname\n";
        print $rf "bytes: $fsize\n";
        print $rf "sha256: $sha\n";
        close $rf;
        print "report: $REPORT\n";
    } else {
        warn "cannot write report $REPORT: $!";
        $allok = 0;
    }
} else {
    warn "cannot create output dir $OUTDIR: $!";
    $allok = 0;
}

exit($allok ? 0 : 1);
