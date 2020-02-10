#!/bin/bash

ISCOOL_INCLUDE_ROOT=$(iscool-shell-config --shell-include)
. "$ISCOOL_INCLUDE_ROOT/options.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"

CONFIGS=()
PLATFORM=
BUILD_TYPE=
BUILD_ROOT=
DISABLE_REMOTE=
PACO_REPOSITORY_ARGS=
SCRIPTS=()
FORCE_BUILD=

add_config()
{
    CONFIGS+=("$1")
}

register_option '--config=<file>' add_config \
                "Source the given Bash file before running the recipes."

set_build_type()
{
    BUILD_TYPE="$1"
}

register_option '--build=<name>' set_build_type \
                "The type of the build (debug, release)."

disable_local()
{
    PACO_REPOSITORY_ARGS="$PACO_REPOSITORY_ARGS --disable-local"
}

register_option '--disable-local' disable_local \
                "Disable the local repository."

disable_remote()
{
    DISABLE_REMOTE=1
    PACO_REPOSITORY_ARGS="$PACO_REPOSITORY_ARGS --disable-remote"
}

register_option '--disable-remote' disable_remote \
                "Disable the remote repository."

force_build()
{
    FORCE_BUILD=1
}

register_option '--force' force_build \
                "Build the packages even if they are up to date."

set_platform()
{
    PLATFORM="$1"
    BUILD_ROOT="$SCRIPT_DIR/build"
}

register_option '--platform=<name>' set_platform \
                "The platform for which to build the libraries."

add_script()
{
    SCRIPTS+=("$1")
}

register_option '--recipe=<path>' add_script \
                "Add a recipe to execute." \
                "All the scripts from $SCRIPT_DIR/recipes."

is_package_in_force_list()
{
    echo "$FORCE_LIST" | grep -q "$1"
}

bake_product()
{
    VERSION=
    NAME=
    RECIPE=
    LOCAL_PACO_ARGUMENTS=("--flavor=$BUILD_TYPE" "--platform=$PLATFORM")
    
    for ARG in "$@"
    do
        case $ARG in
            --version=*)
                VERSION="${ARG#--version=}"
                LOCAL_PACO_ARGUMENTS+=("$ARG")
                ;;
            --name=*)
                NAME="${ARG#--name=}"
                LOCAL_PACO_ARGUMENTS+=("$ARG")
                ;;
            --flavor=*|--platform=*)
                LOCAL_PACO_ARGUMENTS+=("$ARG")
                ;;
            --*)
                printf "Unsupported option '%s'.\\n" "$ARG"
                exit 1
                ;;
            *)
                RECIPE="$ARG"
                ;;
        esac
    done

    [ ! -z "$VERSION" ] \
        || ( printf "Option --version is not set.\\n" >&2; exit 1 )
    [ ! -z "$NAME" ] \
        || ( printf "Option --name is not set.\\n" >&2; exit 1 )
    [ ! -z "$RECIPE" ] \
        || ( printf "No recipe given.\\n" >&2; exit 1 )

    local PACKAGE_STATUS

    if [ -z "$FORCE_BUILD" ]
    then
        PACKAGE_STATUS="$(paco-show $PACO_REPOSITORY_ARGS \
                                   "${LOCAL_PACO_ARGUMENTS[@]}" \
                             | grep ^Status \
                             | cut -d' ' -f2)"
    fi

    if [ -n "$DISABLE_REMOTE" ]
    then
        LOCAL_PACO_ARGUMENTS+=(--disable-remote)
    fi
    
    if [ -n "$FORCE_BUILD" ] || [ "$PACKAGE_STATUS" = "unknown" ] \
           || is_package_in_force_list "$NAME"
    then
        paco-uninstall "--name=$NAME" \
                       "--prefix=$PACKAGE_INSTALL_PREFIX"
        
        LOCAL_INSTALL_PREFIX="$UPSTREAM_INSTALL_DIR/$NAME-$VERSION"

        rm -fr "$LOCAL_INSTALL_PREFIX"
        mkdir -p "$LOCAL_INSTALL_PREFIX"
        
        "$RECIPE" "$LOCAL_INSTALL_PREFIX"

        paco-publish --root="$LOCAL_INSTALL_PREFIX" \
                     "${LOCAL_PACO_ARGUMENTS[@]}"
    fi

    paco-install "${LOCAL_PACO_ARGUMENTS[@]}" \
                 "--prefix=$PACKAGE_INSTALL_PREFIX"
}

get_package_version()
{
    local RESULT
    RESULT="$(paco-info --prefix "$PACKAGE_INSTALL_PREFIX" --name "$1" \
                 | grep '^Version:' \
                 | cut -d: -f2)"

    [ ! -z "$RESULT" ] || exit 1
    echo "$RESULT"
}

extract_parameters "$@"

check_option_is_set "--build" "$BUILD_TYPE"
check_option_is_set "--platform" "$PLATFORM"

BUILD_TYPE_DIR="$BUILD_ROOT/$PLATFORM/$BUILD_TYPE"

export PLATFORM
export BUILD_TYPE
export PACKAGE_INSTALL_PREFIX="$BUILD_TYPE_DIR/prefix"
export UPSTREAM_INSTALL_DIR="$BUILD_TYPE_DIR/upstream-install"
export UPSTREAM_BUILD_DIR="$BUILD_TYPE_DIR/upstream-build"
export UPSTREAM_SOURCE_DIR="$BUILD_ROOT/upstream-source"
export PACO_REPOSITORY_ARGS
export DISABLE_REMOTE
export FORCE_BUILD
export -f is_package_in_force_list
export -f bake_product
export -f get_package_version

export CFLAGS="$CFLAGS -I$PACKAGE_INSTALL_PREFIX/include"
export CXXFLAGS="$CXXFLAGS -I$PACKAGE_INSTALL_PREFIX/include"
export PATH="$SCRIPT_DIR/tools/:$PATH"

mkdir -p "$BUILD_ROOT" \
      "$PACKAGE_INSTALL_PREFIX" \
      "$UPSTREAM_BUILD_DIR" \
      "$UPSTREAM_INSTALL_DIR" \
      "$UPSTREAM_SOURCE_DIR"

printf "Building for platform '%s'.\n" "$PLATFORM"

for CONFIG in "${CONFIGS[@]}"
do
    . "$CONFIG"
done

ENVIRONMENT_VARIABLES="$SCRIPT_DIR/environment/$PLATFORM.sh"

[ ! -f "$ENVIRONMENT_VARIABLES" ] || . "$ENVIRONMENT_VARIABLES"

[ "${#SCRIPTS}" != 0 ] || SCRIPTS=("$SCRIPT_DIR"/recipes/*)

run-all-scripts "${SCRIPTS[@]}"
