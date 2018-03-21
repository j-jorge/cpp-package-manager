#!/bin/bash

INCLUDE_ROOT=$(iscool-shell-config --shell-include)

. "$INCLUDE_ROOT/testing.sh"
. "$INCLUDE_ROOT/temporaries.sh"

PATH="$(dirname "${BASH_SOURCE[0]}")/../prefix/bin:$PATH"

ROOT=$(make_temporary_directory)

echo 1 > "$ROOT/.hidden"
echo 2 > "$ROOT/file"
mkdir "$ROOT/dir1"
mkdir "$ROOT/dir2"
echo 3 > "$ROOT/dir2/file"

ARCHIVE=$(paco-archive --root="$ROOT" --version=test/1)

[ -f "$ARCHIVE" ] || test_failed $LINENO

TARGET=$(make_temporary_directory)

tar xf "$ARCHIVE" -C "$TARGET"

diff --brief --recursive "$ROOT" "$TARGET" >/dev/null || test_failed $LINENO

rm -f "$ARCHIVE"

test_end
