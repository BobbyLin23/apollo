#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
RUN="$ROOT/.cursor/skills/verify-apollo/run"

for file in server.pid web.pid listen-3000.pid listen-3001.pid; do
  if [[ ! -f "$RUN/$file" ]]; then
    echo "doctor: no verification run ($file missing). Refusing to drive an instance this run did not start." >&2
    exit 1
  fi
done

is_in_tree() {
  local current="$1" ancestor="$2" guard=0
  while [[ -n "$current" && "$current" != "0" && "$current" != "1" && $guard -lt 25 ]]; do
    if [[ "$current" == "$ancestor" ]]; then
      return 0
    fi
    current="$(ps -o ppid= -p "$current" 2>/dev/null | tr -d ' ' || true)"
    guard=$((guard + 1))
  done
  return 1
}

server_pid="$(cat "$RUN/server.pid")"
web_pid="$(cat "$RUN/web.pid")"
listen_api="$(cat "$RUN/listen-3000.pid")"
listen_web="$(cat "$RUN/listen-3001.pid")"

ps -p "$server_pid" >/dev/null
ps -p "$web_pid" >/dev/null
is_in_tree "$listen_api" "$server_pid"
is_in_tree "$listen_web" "$web_pid"

now_api="$(lsof -nP -iTCP:3000 -sTCP:LISTEN -t | head -n 1)"
now_web="$(lsof -nP -iTCP:3001 -sTCP:LISTEN -t | head -n 1)"
[[ "$now_api" == "$listen_api" ]]
[[ "$now_web" == "$listen_web" ]]

root_body="$(curl -fsS http://localhost:3000/)"
health_body="$(curl -fsS http://localhost:3000/trpc/healthCheck)"
web_code="$(curl -fsS -o /dev/null -w "%{http_code}" http://localhost:3001/)"
[[ "$root_body" == "OK" ]]
[[ "$health_body" == '{"result":{"data":"OK"}}' ]]
[[ "$web_code" == "200" ]]

echo "doctor: ok"
echo "web: http://localhost:3001/"
echo "api: http://localhost:3000/"
echo "health: $health_body"
echo "listeners: 3000=$listen_api 3001=$listen_web"
echo "auth routes are not proved by this doctor; they need the configured database"
