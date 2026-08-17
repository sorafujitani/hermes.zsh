#!/bin/sh
set -eu

version=${1:?usage: scripts/rollback.sh VERSION}
root=$(cd "$(dirname "$0")/.." && pwd)
"$root/scripts/activate-version.sh" "$version"
echo "activated Hermes $version; restart with: hermes server restart"
