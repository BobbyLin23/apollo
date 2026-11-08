#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
ART="$ROOT/.cursor/skills/verify-apollo/artifacts/api-status"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

"$ROOT/.cursor/skills/verify-apollo/scripts/doctor.sh" >/dev/null

if [[ ! -x "$CHROME" ]]; then
  echo "Google Chrome is required at $CHROME" >&2
  exit 1
fi

mkdir -p "$ART"
profile="$(mktemp -d)"
dom="$(mktemp)"
trap 'rm -rf "$profile" "$dom"' EXIT

# Throwaway profile so a developer session cookie cannot force a database lookup.
"$CHROME" \
  --headless=new \
  --disable-gpu \
  --no-first-run \
  --user-data-dir="$profile" \
  --window-size=1280,800 \
  --virtual-time-budget=8000 \
  --timeout=15000 \
  --screenshot="$ART/home.png" \
  "http://localhost:3001/" \
  --dump-dom >"$dom" 2>"$ROOT/.cursor/skills/verify-apollo/run/chrome.err"

perl - "$dom" "$ART/home.aria.txt" <<'PERL'
use strict;
use warnings;
my ($src, $dest) = @ARGV;
open my $in, "<:utf8", $src or die $!;
local $/;
my $html = <$in>;
close $in;
die "rendered DOM has no API Status heading\n" unless $html =~ />API Status<\/h2>/;
die "rendered status is not Connected\n" unless $html =~ />Connected<\/span>/;
die "rendered header has no Home link\n" unless $html =~ />Home</;
die "rendered header has no Dashboard link\n" unless $html =~ />Dashboard</;
open my $out, ">:utf8", $dest or die $!;
print $out "API Status: Connected\nHome: present\nDashboard: present\n";
close $out;
PERL

curl -fsS http://localhost:3000/trpc/healthCheck >"$ART/health.json"
[[ "$(cat "$ART/health.json")" == '{"result":{"data":"OK"}}' ]]
echo "capture-home: ok $ART"
