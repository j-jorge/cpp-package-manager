#!/bin/bash

INCLUDE_ROOT=$(iscool-shell-config --shell-include)

. "$INCLUDE_ROOT/testing.sh"
. "$INCLUDE_ROOT/temporaries.sh"

export PACO_LOCAL_CACHE=$(make_temporary_directory)

PATH="$(dirname "${BASH_SOURCE[0]}")/../prefix/bin:$PATH"

ROOT=$(make_temporary_directory)

echo 1 > "$ROOT/with space"
echo 2 > "$ROOT/with  more   spaces"
echo 3 > "$ROOT/  spaces!  "

VERSION=test-version
FLAVOR=test-flavor
NAME=test-name
PLATFORM=test-platform

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

[[ -f "$TARGET/with space" ]] || test_failed "$LINENO"
[[ -f "$TARGET/with  more   spaces" ]] || test_failed "$LINENO"
[[ -f "$TARGET/  spaces!  " ]] || test_failed "$LINENO"

paco-uninstall --name="$NAME" \
               --prefix="$TARGET"

[[ ! -f "$TARGET/with space" ]] || test_failed "$LINENO"
[[ ! -f "$TARGET/with  more   spaces" ]] || test_failed "$LINENO"
[[ ! -f "$TARGET/  spaces!  " ]] || test_failed "$LINENO"

test_end
