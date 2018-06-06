#!/bin/bash

INCLUDE_ROOT=$(iscool-shell-config --shell-include)

. "$INCLUDE_ROOT/testing.sh"
. "$INCLUDE_ROOT/temporaries.sh"

export PACO_LOCAL_CACHE=$(make_temporary_directory)

PATH="$(dirname "${BASH_SOURCE[0]}")/../prefix/bin:$PATH"

ROOT=$(make_temporary_directory)

echo 1 > "$ROOT/file_1"
echo 1 > "$ROOT/file_2"

FLAVOR=flow-test-flavor
NAME=flow-test-name
PLATFORM=flow-test-platform

paco-publish --root="$ROOT" \
             --name="$NAME" \
             --version=1 \
             --disable-remote \
             --platform="$PLATFORM" \
             --flavor="$FLAVOR"

echo 2 > "$ROOT/file_1"
rm "$ROOT/file_2"

paco-publish --root="$ROOT" \
             --name="$NAME" \
             --version=2 \
             --disable-remote \
             --platform="$PLATFORM" \
             --flavor="$FLAVOR"

TARGET=$(make_temporary_directory)

paco-install --disable-remote \
             --platform="$PLATFORM" \
             --name="$NAME" \
             --flavor="$FLAVOR" \
             --version=1 \
             --prefix="$TARGET"

[ "$(cat "$TARGET/file_1")" = 1 ] || test_failed $LINENO
[ -f "$TARGET/file_2" ] || test_failed $LINENO

paco-install --disable-remote \
             --platform="$PLATFORM" \
             --name="$NAME" \
             --flavor="$FLAVOR" \
             --version=2 \
             --prefix="$TARGET"

[ "$(cat "$TARGET/file_1")" = 2 ] || test_failed $LINENO
[ ! -e "$TARGET/file_2" ] || test_failed $LINENO

test_end
