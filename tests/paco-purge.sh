#!/bin/bash

INCLUDE_ROOT=$(iscool-shell-config --shell-include)

. "$INCLUDE_ROOT/testing.sh"
. "$INCLUDE_ROOT/temporaries.sh"

export PACO_LOCAL_CACHE=$(make_temporary_directory)

PATH="$(dirname "${BASH_SOURCE[0]}")/../prefix/bin:$PATH"

ROOT=$(make_temporary_directory)

echo 1 > "$ROOT/file_1"
echo 1 > "$ROOT/file_2"

for NAME in name-1 name-2
do
    for PLATFORM in platform-1 platform-2
    do
        for FLAVOR in flavor-1 flavor-2
        do
            for VERSION in version-1 version-2
            do
                paco-publish --root="$ROOT" \
                             --name="$NAME" \
                             --version="$VERSION" \
                             --disable-remote \
                             --platform="$PLATFORM" \
                             --flavor="$FLAVOR"
            done
        done
    done
done

[ "$(paco-list --disable-remote | wc -l)" -eq 16 ] || test_failed $LINENO

yes | paco-purge --disable-remote --name="name-1"

[ "$(paco-list --disable-remote | wc -l)" -eq 8 ] || test_failed $LINENO
[ -z "$(paco-list --disable-remote --name="name-1")" ] || test_failed $LINENO

yes | paco-purge --disable-remote --platform="platform-2"
[ "$(paco-list --disable-remote | wc -l)" -eq 4 ] || test_failed $LINENO
[ -z "$(paco-list --disable-remote --platform="platform-2")" ] \
    || test_failed $LINENO

yes | paco-purge --disable-remote --version="version-1"
[ "$(paco-list --disable-remote | wc -l)" -eq 2 ] || test_failed $LINENO
[ -z "$(paco-list --disable-remote --version="version-1")" ] \
    || test_failed $LINENO

yes | paco-purge --disable-remote --flavor="flavor-2"
[ "$(paco-list --disable-remote | wc -l)" -eq 1 ] || test_failed $LINENO
[ -z "$(paco-list --disable-remote --flavor="flavor-2")" ] \
    || test_failed $LINENO

yes | paco-purge --disable-remote
[ "$(paco-list --disable-remote | wc -l)" -eq 0 ] || test_failed $LINENO

test_end
