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
VERSION=1.34.2

paco-publish --root="$ROOT" \
             --name="$NAME" \
             --version="$VERSION" \
             --disable-remote \
             --platform="$PLATFORM" \
             --flavor="$FLAVOR"

TARGET=$(make_temporary_directory)

paco-install --disable-remote \
             --platform="$PLATFORM" \
             --name="$NAME" \
             --flavor="$FLAVOR" \
             --version="$VERSION" \
             --prefix="$TARGET"

INFO="$(paco-info --prefix="$TARGET" --name="$NAME")"
EXPECTED="Version:$VERSION"

[ "$INFO" = "$EXPECTED" ] || test_failed $LINENO

INFO="$(paco-info --prefix="$TARGET" --name=nope)"
EXPECTED="Package 'nope' is not installed."

[ "$INFO" = "$EXPECTED" ] || test_failed $LINENO

test_end
