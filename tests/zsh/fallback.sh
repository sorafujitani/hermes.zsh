#!/bin/sh
set -eu

binary=${HERMES_BIN:?HERMES_BIN must point to hermes}
runtime=$(mktemp -d)
chmod 700 "$runtime"
output=$(HERMES_DISABLE_DAEMON=1 HERMES_RUNTIME_DIR="$runtime" "$binary" \
  --mode=preprompt --input.template='echo {{VALUE}}')
test "$(printf '%s\n' "$output" | sed -n '1p')" = success
test ! -e "$runtime/daemon.sock"

# Explicit Hermes settings are applied on a per-request basis.
output=$(HERMES_DISABLE_DAEMON=1 \
  HERMES_RUNTIME_DIR="$runtime" "$binary" \
  --mode=preprompt --input.template='native {{VALUE}}')
printf '%s\n' "$output" | grep -q '^native  $'
test ! -e "$runtime/daemon.sock"
