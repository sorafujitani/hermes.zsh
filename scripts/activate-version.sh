#!/bin/sh
set -eu

prefix=${HERMES_INSTALL_PREFIX:-"$HOME/.local"}
version=${1:?usage: scripts/activate-version.sh VERSION}
release="$prefix/lib/hermes/releases/$version"
test -x "$release/hermes" || {
  echo "Hermes release is not installed: $version" >&2
  exit 2
}

mkdir -p "$prefix/bin" "$prefix/lib/hermes"
temporary_link="$prefix/lib/hermes/.current-$$"
ln -s "releases/$version" "$temporary_link"
if mv --version >/dev/null 2>&1; then
  mv -Tf "$temporary_link" "$prefix/lib/hermes/current"
else
  mv -fh "$temporary_link" "$prefix/lib/hermes/current"
fi

for name in hermes hermesd; do
  link="$prefix/bin/.$name-$$"
  ln -s "$prefix/lib/hermes/current/$name" "$link"
  mv -f "$link" "$prefix/bin/$name"
done
for name in hermes.zsh shells docs spec; do
  link="$prefix/lib/hermes/.$name-$$"
  ln -s "current/$name" "$link"
  rm -f "$prefix/lib/hermes/$name"
  mv "$link" "$prefix/lib/hermes/$name"
done

printf '%s\n' "$version" > "$prefix/lib/hermes/ACTIVE_VERSION"
