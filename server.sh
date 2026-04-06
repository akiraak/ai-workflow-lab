#!/bin/bash
cd "$(dirname "$0")"

PID_FILE=".vitepress/dev.pid"

# Stop previous process if running
if [ -f "$PID_FILE" ]; then
  OLD_PID=$(cat "$PID_FILE")
  if kill -0 "$OLD_PID" 2>/dev/null; then
    echo "Stopping previous server (PID: $OLD_PID)..."
    kill "$OLD_PID"
    sleep 1
  fi
  rm -f "$PID_FILE"
fi

npx vitepress dev --host &
echo $! > "$PID_FILE"
echo "Server started (PID: $!)"
