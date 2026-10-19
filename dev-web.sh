#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY_DIR="$ROOT_DIR/deploy/market-proxy"
PROXY_PORT="${PROXY_PORT:-8787}"
WEB_PORT="${WEB_PORT:-4173}"
PROXY_URL="http://127.0.0.1:$PROXY_PORT"
PROXY_LOG="$ROOT_DIR/.dart_tool/market-proxy.log"
PROXY_PID=""

info() {
  printf '\033[1;34m[TrendStock]\033[0m %s\n' "$1"
}

fail() {
  printf '\033[1;31m[TrendStock]\033[0m %s\n' "$1" >&2
  exit 1
}

stop_process_tree() {
  local pid="$1"
  local child
  while read -r child; do
    [[ -n "$child" ]] && stop_process_tree "$child"
  done < <(pgrep -P "$pid" 2>/dev/null || true)
  kill "$pid" 2>/dev/null || true
}

cleanup() {
  if [[ -n "$PROXY_PID" ]]; then
    info "Stopping market proxy..."
    stop_process_tree "$PROXY_PID"
  fi
}
trap cleanup EXIT INT TERM

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.nvm/nvm.sh"
  nvm use 22 >/dev/null 2>&1 || true
fi

command -v node >/dev/null 2>&1 || fail "Node.js is not installed. Install Node.js 22 first."
NODE_MAJOR="$(node -p "Number(process.versions.node.split('.')[0])")"
if (( NODE_MAJOR < 22 )); then
  fail "Node.js 22+ is required. Run: nvm install 22 && nvm use 22"
fi

command -v flutter >/dev/null 2>&1 || fail "Flutter is not available in PATH."

mkdir -p "$ROOT_DIR/.dart_tool"

if [[ ! -x "$PROXY_DIR/node_modules/.bin/wrangler" ]]; then
  info "Installing market proxy dependencies..."
  npm --prefix "$PROXY_DIR" install
fi

if curl --silent --output /dev/null --max-time 1 "$PROXY_URL/"; then
  info "Reusing market proxy on port $PROXY_PORT."
else
  info "Starting market proxy on port $PROXY_PORT..."
  npm --prefix "$PROXY_DIR" run dev -- \
    --ip 127.0.0.1 --port "$PROXY_PORT" >"$PROXY_LOG" 2>&1 &
  PROXY_PID=$!

  for _ in {1..30}; do
    if curl --silent --output /dev/null --max-time 1 "$PROXY_URL/"; then
      break
    fi
    if ! kill -0 "$PROXY_PID" 2>/dev/null; then
      tail -n 30 "$PROXY_LOG" >&2 || true
      fail "Market proxy failed to start."
    fi
    sleep 0.5
  done

  if ! curl --silent --output /dev/null --max-time 1 "$PROXY_URL/"; then
    tail -n 30 "$PROXY_LOG" >&2 || true
    fail "Timed out waiting for market proxy."
  fi
  info "Market proxy is ready. Log: $PROXY_LOG"
fi

if [[ ! -f "$ROOT_DIR/.dart_tool/package_config.json" ]]; then
  info "Installing Flutter dependencies..."
  (cd "$ROOT_DIR" && flutter pub get)
fi

info "Starting Web: http://127.0.0.1:$WEB_PORT"
info "Press r for hot reload, q or Ctrl+C to stop."

cd "$ROOT_DIR"
flutter run \
  -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port "$WEB_PORT" \
  --dart-define="MARKET_PROXY_BASE_URL=$PROXY_URL"
