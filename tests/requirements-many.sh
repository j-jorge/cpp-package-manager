#!/bin/bash

set -euo pipefail

INCLUDE_ROOT=$(iscool-shell-config --shell-include)

. "$INCLUDE_ROOT/testing.sh"
. "$INCLUDE_ROOT/temporaries.sh"

export PACO_LOCAL_CACHE=$(make_temporary_directory)

PATH="$(dirname "${BASH_SOURCE[0]}")/../prefix/bin:$PATH"

ROOT=$(make_temporary_directory)

FLAVOR=requirements-test-flavor
PLATFORM=requirements-test-platform

archive_and_upload()
{
    local NAME="$1"
    local VERSION="$2"
    shift 2

    ARCHIVE=$(paco-archive --root="$ROOT" \
                           --name="$NAME" \
                           --version="$VERSION" \
                           "$@")

    [ -f "$ARCHIVE" ] || return 1

    paco-upload --file="$ARCHIVE" \
                --disable-remote \
                --platform="$PLATFORM" \
                --flavor="$FLAVOR"

    rm -f "$ARCHIVE"
    rm -fr "${ROOT:?}"/*
}

check_installed()
{
    local NAME="$1"
    local VERSION="$2"
    local PACKAGE_STATUS

    PACKAGE_STATUS="$(paco-show --disable-remote \
                                --platform="$PLATFORM" \
                                --name="$NAME" \
                                --flavor="$FLAVOR" \
                                --version="$VERSION" \
                          | head -n 1)"

    [ "$PACKAGE_STATUS" = "Status: up-to-date" ]
}

# package-a, version 1
echo 1 > "$ROOT/mine"
echo 2 > "$ROOT/file"
mkdir "$ROOT/dir"
echo 3 > "$ROOT/dir/file"

archive_and_upload package-a 1 || test_failed $LINENO

# package-b, depends on package-a
echo "hello" > "$ROOT/it-s-a-me"

archive_and_upload package-b 1 --requires package-a=1 \
    || test_failed $LINENO

# package-c
echo "C" > "$ROOT/see"

archive_and_upload package-c 1 --requires package-a=1 \
    || test_failed $LINENO

# package-d, depends on package-c and package-b
echo "d" > "$ROOT/some_file"

archive_and_upload package-d 1 --requires package-c=1 package-b=1 \
    || test_failed $LINENO

# Install package-d
TARGET=$(make_temporary_directory)
LOG=$(make_temporary_file)
paco-install --disable-remote \
             --platform="$PLATFORM" \
             --name="package-d" \
             --flavor="$FLAVOR" \
             --version="1" \
             --prefix="$TARGET" \
             > "$LOG" \
             || test_failed $LINENO

grep --quiet -F 'Installing package "package-a" in version 1.' "$LOG" \
    || test_failed $LINENO
[[ $(grep --count -F 'Installing package "package-a" in version 1.' "$LOG") \
       -eq 1 ]] \
    || test_failed $LINENO
grep --quiet -F 'Installing package "package-b" in version 1.' "$LOG" \
    || test_failed $LINENO
grep --quiet -F 'Installing package "package-c" in version 1.' "$LOG" \
    || test_failed $LINENO
grep --quiet -F 'Installing package "package-d" in version 1.' "$LOG" \
    || test_failed $LINENO

check_installed package-d 1 || test_failed $LINENO
check_installed package-c 1 || test_failed $LINENO
check_installed package-b 1 || test_failed $LINENO
check_installed package-a 1 || test_failed $LINENO

# Files from package-a.
diff --brief "$TARGET/mine" <(echo 1) > /dev/null || test_failed $LINENO
diff --brief "$TARGET/file" <(echo 2) > /dev/null || test_failed $LINENO
diff --brief "$TARGET/dir/file" <(echo 3) > /dev/null || test_failed $LINENO

# Files from package-b
diff --brief "$TARGET/it-s-a-me" <(echo hello) > /dev/null || test_failed $LINENO

# Files from package-c
diff --brief "$TARGET/see" <(echo C) > /dev/null || test_failed $LINENO

# Files from package-d
diff --brief "$TARGET/some_file" <(echo d) > /dev/null || test_failed $LINENO

test_end
