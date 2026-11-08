#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
RUN="$ROOT/.cursor/skills/verify-apollo/run"
ART="$ROOT/.cursor/skills/verify-apollo/artifacts"

if [[ ! -d "$RUN" ]]; then
  echo "cleanup: no run directory"
  exit 0
fi

kill_tree() {
  local pid="$1"
  local kid
  for kid in $(pgrep -P "$pid" 2>/dev/null || true); do
    kill_tree "$kid"
  done
  kill "$pid" 2>/dev/null || true
}

if [[ -f "$RUN/server.pid" ]]; then
  server_pid="$(cat "$RUN/server.pid")"
  if ps -p "$server_pid" -o command= 2>/dev/null | grep -q "bun"; then
    kill_tree "$server_pid"
  fi
fi

if [[ -f "$RUN/web.pid" ]]; then
  web_pid="$(cat "$RUN/web.pid")"
  if ps -p "$web_pid" -o command= 2>/dev/null | grep -q "bun"; then
    kill_tree "$web_pid"
  fi
fi

rm -rf "$RUN"
if [[ ! -d "$ART" ]]; then
  echo "cleanup: stopped the run; no evidence directory yet"
else
  echo "cleanup: stopped the run; evidence remains in $ART"
fi
