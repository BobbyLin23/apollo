#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
RUN="$ROOT/.cursor/skills/verify-apollo/run"
mkdir -p "$RUN"

if lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1 || lsof -nP -iTCP:3001 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "port 3000 or 3001 is already in use; refusing to start a second Apollo" >&2
  exit 1
fi

stop_started() {
  if [[ -f "$RUN/server.pid" ]]; then
    kill "$(cat "$RUN/server.pid")" 2>/dev/null || true
  fi
  if [[ -f "$RUN/web.pid" ]]; then
    kill "$(cat "$RUN/web.pid")" 2>/dev/null || true
  fi
}
trap stop_started ERR

# New session so this script exiting does not SIGHUP the dev servers.
start_detached() {
  local pidfile="$1" logfile="$2" workdir="$3"
  shift 3
  perl -MPOSIX -e 'POSIX::setsid(); chdir $ARGV[0] or die $!; exec @ARGV[1 .. $#ARGV] or die $!' \
    -- "$workdir" "$@" >"$logfile" 2>&1 </dev/null &
  echo $! >"$pidfile"
}

start_detached "$RUN/server.pid" "$RUN/server.log" "$ROOT/apps/server" bun run dev
start_detached "$RUN/web.pid" "$RUN/web.log" "$ROOT/apps/web" bun run dev

ready=0
for _ in $(seq 1 45); do
  if grep -q "Started development server" "$RUN/server.log" \
    && grep -q "localhost:3001" "$RUN/web.log" \
    && [[ "$(curl -fsS http://localhost:3000/ 2>/dev/null || true)" == "OK" ]] \
    && [[ "$(curl -fsS http://localhost:3000/trpc/healthCheck 2>/dev/null || true)" == '{"result":{"data":"OK"}}' ]]; then
    ready=1
    break
  fi
  sleep 1
done

if [[ "$ready" != 1 ]]; then
  echo "Apollo did not become usable. See $RUN/server.log and $RUN/web.log" >&2
  exit 1
fi

lsof -nP -iTCP:3000 -sTCP:LISTEN -t | head -n 1 >"$RUN/listen-3000.pid"
lsof -nP -iTCP:3001 -sTCP:LISTEN -t | head -n 1 >"$RUN/listen-3001.pid"
trap - ERR
echo "launch: ok http://localhost:3001/ api http://localhost:3000/"
