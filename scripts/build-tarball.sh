#!/usr/bin/env bash
# Reproducibly build the timed-boot-resync distribution tarball.
#
# Canonical environment: ubuntu-latest (GNU tar + gzip -n) in GitHub Actions.
# Determinism contract: sorted entry order, epoch mtime, uid/gid 0, numeric
# owner, ustar format, and gzip -n (no original filename / timestamp). These
# make the produced sha256 stable, which the Homebrew formula pins and CI gates.
#
# Usage: scripts/build-tarball.sh [version]   # version defaults to ./VERSION
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-$(cat "$ROOT/VERSION")}"
SRC="$ROOT/src"
STAGE="$(mktemp -d)"
DIST="$ROOT/dist"
PKGDIR="timed-boot-resync-${VERSION}"
OUT="$DIST/timed-boot-resync-${VERSION}.tar.gz"

mkdir -p "$STAGE/$PKGDIR" "$DIST"
cp "$SRC/timed-boot-resync"      "$STAGE/$PKGDIR/timed-boot-resync"
cp "$SRC/timed-boot-resync.conf" "$STAGE/$PKGDIR/timed-boot-resync.conf"
cp "$ROOT/README.md"             "$STAGE/$PKGDIR/README.md"
cp "$ROOT/LICENSE"               "$STAGE/$PKGDIR/LICENSE"

chmod 0755 "$STAGE/$PKGDIR/timed-boot-resync"
chmod 0644 "$STAGE/$PKGDIR/timed-boot-resync.conf" \
           "$STAGE/$PKGDIR/README.md" \
           "$STAGE/$PKGDIR/LICENSE"

# Reproducible tar -> reproducible gzip.
tar --sort=name --mtime="@0" --owner=0 --group=0 --numeric-owner \
    --format=ustar -C "$STAGE" -cf - "$PKGDIR" \
  | gzip -n -9 > "$OUT"

sha256sum "$OUT"
rm -rf "$STAGE"
