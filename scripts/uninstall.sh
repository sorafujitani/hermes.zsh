#!/bin/sh
set -eu

prefix=${HERMES_INSTALL_PREFIX:-"$HOME/.local"}
case "$prefix" in
  ""|/) echo "refusing unsafe uninstall prefix: $prefix" >&2; exit 2 ;;
esac
if [ -x "$prefix/bin/hermes" ]; then
  "$prefix/bin/hermes" server stop >/dev/null 2>&1 || true
fi
rm -f "$prefix/bin/hermes" "$prefix/bin/hermesd"
rm -rf "$prefix/lib/hermes"
echo "Hermes executables removed. User configuration and history were preserved."
