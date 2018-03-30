#!/bin/bash

INCLUDE_ROOT=$(iscool-shell-config --shell-include)

. "$INCLUDE_ROOT/testing.sh"
. "$INCLUDE_ROOT/temporaries.sh"

export PACO_LOCAL_CACHE=$(make_temporary_directory)

PATH="$(dirname "${BASH_SOURCE[0]}")/../prefix/bin:$PATH"

ROOT=$(make_temporary_directory)

echo 1 > "$ROOT/.hidden"
echo 2 > "$ROOT/file"
mkdir "$ROOT/dir1"
mkdir "$ROOT/dir2"
echo 3 > "$ROOT/dir2/file"

VERSION=publish-test-version
FLAVOR=publish-test-flavor
NAME=publish-test-name
PLATFORM=publish-test-platform

paco-publish --root="$ROOT" \
             --name="$NAME" \
             --version="$VERSION" \
             --disable-remote \
             --platform="$PLATFORM" \
             --flavor="$FLAVOR"

PACKAGE_STATUS="$(paco-show  --disable-remote \
                            --platform="$PLATFORM" \
                            --name="$NAME" \
                            --flavor="$FLAVOR" \
                            --version="$VERSION" \
                     | head -n 1)"               

[ "$PACKAGE_STATUS" = "Status: up-to-date" ] || test_failed $LINENO

TARGET=$(make_temporary_directory)

paco-install --disable-remote \
             --platform="$PLATFORM" \
             --name="$NAME" \
             --flavor="$FLAVOR" \
             --version="$VERSION" \
             --prefix="$TARGET"
           
diff --brief --recursive "$ROOT" "$TARGET" >/dev/null || test_failed $LINENO

test_end
