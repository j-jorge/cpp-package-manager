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
mkdir -p "$ROOT/dir3/subdir"
echo 4 > "$ROOT/dir3/subdir/file"

VERSION=flow-test-version
FLAVOR=flow-test-flavor
NAME=flow-test-name
PLATFORM=flow-test-platform

ARCHIVE=$(paco-archive --root="$ROOT" \
                       --name="$NAME" \
                       --version="$VERSION")

[ -f "$ARCHIVE" ] || test_failed $LINENO

paco-upload --file="$ARCHIVE" \
            --disable-remote \
            --platform="$PLATFORM" \
            --flavor="$FLAVOR"

rm -f "$ARCHIVE"

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

RELATIVE_PATH_BEGIN=$(( ${#ROOT} + 1 ))

find "$ROOT" -mindepth 1 \
    | while read -r P
do
    RELATIVE_PATH=${P:$RELATIVE_PATH_BEGIN}
    
    (
        if [ -f "$P" ]
        then
            diff --brief "$P" "$TARGET/$RELATIVE_PATH" > /dev/null
        else
            [ -d "$TARGET/$RELATIVE_PATH" ]
        fi
    ) || (
        printf "'%s' and '%s' do not match.\n" "$P" "$TARGET/$RELATIVE_PATH"
        test_failed $LINENO
    )
done

paco-uninstall --name="$NAME" \
               --prefix="$TARGET"

REMAINING_FILES="$(find "$TARGET" -mindepth 1 -maxdepth 1 | wc -l)"
[ "$REMAINING_FILES" -eq 0 ] || test_failed $LINENO

test_end
