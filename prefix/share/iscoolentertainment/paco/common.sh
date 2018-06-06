#!/bin/bash

: "${PACO_LOCAL_CACHE:="$HOME/.cache/iscool/paco"}"
PACO_PACKAGE_EXTENSION=.tar.gz
PACO_INSTALL_METADATA_DIR=var/lib/iscoolentertainment/paco/install/metadata

install_manifest_file()
{
    local INSTALL_PREFIX="$1"
    local NAME="$2"

    local PACO_INSTALL_MANIFEST_DIR=var/lib/iscoolentertainment/paco/install/manifest

    echo "$INSTALL_PREFIX/$PACO_INSTALL_MANIFEST_DIR/$NAME"
}

install_metadata_file()
{
    local INSTALL_PREFIX="$1"
    local NAME="$2"

    local PACO_INSTALL_METADATA_DIR=var/lib/iscoolentertainment/paco/install/metadata

    echo "$INSTALL_PREFIX/$PACO_INSTALL_METADATA_DIR/$NAME"
}
