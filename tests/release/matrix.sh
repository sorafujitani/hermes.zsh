#!/bin/sh
set -eu

binary=${HERMES_BIN:?HERMES_BIN must point to a produced release binary}
root=$(mktemp -d)
home="$root/home"
prefix="$root/prefix"
runtime="$root/runtime"
mkdir -p "$home" "$prefix/bin" "$prefix/lib/hermes/releases/v1" "$runtime"
chmod 700 "$home" "$runtime"
trap 'HOME="$home" HERMES_RUNTIME_DIR="$runtime" "$prefix/bin/hermes" server stop >/dev/null 2>&1 || true' EXIT HUP INT TERM

# Clean install from the produced artifact payload.
cp "$binary" "$prefix/lib/hermes/releases/v1/hermes"
cp "$binary" "$prefix/lib/hermes/releases/v1/hermesd"
cp hermes.zsh "$prefix/lib/hermes/releases/v1/hermes.zsh"
cp -R shells docs spec scripts "$prefix/lib/hermes/releases/v1/"
HERMES_INSTALL_PREFIX="$prefix" scripts/activate-version.sh v1
HOME="$home" HERMES_RUNTIME_DIR="$runtime" "$prefix/bin/hermes" server start >/dev/null
HOME="$home" HERMES_RUNTIME_DIR="$runtime" "$prefix/bin/hermes" server status >/dev/null

# An interrupted extraction does not change the active symlink.
mkdir "$prefix/lib/hermes/releases/.staging-v2-interrupted"
printf partial > "$prefix/lib/hermes/releases/.staging-v2-interrupted/hermes"
test "$(readlink "$prefix/lib/hermes/current")" = releases/v1

# Upgrade, daemon replacement, and rollback preserve history.
cp -R "$prefix/lib/hermes/releases/v1" "$prefix/lib/hermes/releases/v2"
HERMES_INSTALL_PREFIX="$prefix" scripts/activate-version.sh v2
test "$(readlink "$prefix/lib/hermes/current")" = releases/v2
HOME="$home" HERMES_RUNTIME_DIR="$runtime" "$prefix/bin/hermes" server restart >/dev/null
HOME="$home" HERMES_RUNTIME_DIR="$runtime" "$prefix/bin/hermes" history log "release-matrix" >/dev/null
HOME="$home" HERMES_RUNTIME_DIR="$runtime" "$prefix/bin/hermes" server stop
test ! -e "$runtime/daemon.sock"
HOME="$home" HERMES_INSTALL_PREFIX="$prefix" scripts/rollback.sh v1 >/dev/null
test "$(readlink "$prefix/lib/hermes/current")" = releases/v1
HOME="$home" HERMES_RUNTIME_DIR="$runtime" "$prefix/bin/hermes" server start >/dev/null
HOME="$home" HERMES_RUNTIME_DIR="$runtime" "$prefix/bin/hermes" history query --commands | grep -q release-matrix

# Uninstall keeps history but leaves no process or socket.
HOME="$home" HERMES_RUNTIME_DIR="$runtime" HERMES_INSTALL_PREFIX="$prefix" scripts/uninstall.sh >/dev/null
test ! -e "$runtime/daemon.sock"
test ! -e "$prefix/lib/hermes"
test -f "$home/.local/share/hermes/history.sqlite3"
