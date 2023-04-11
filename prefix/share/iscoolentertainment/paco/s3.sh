#!/bin/bash

S3_CONFIG=$(dirname "${BASH_SOURCE[0]}")/s3-credentials.conf
: "${PACO_S3_ROOT="s3://cpp-packages"}"
: "${PACO_S3_BUCKET="paco"}"
PACO_S3_BUCKET_ROOT="$PACO_S3_ROOT/$PACO_S3_BUCKET"
S3CMD_COMMON_ARGS=(--config="$S3_CONFIG"
                   --access_key="${PACO_S3_ACCESS_KEY:-}"
                   --secret_key="${PACO_S3_SECRET_KEY:-}")

s3_put()
{
    FILE="$1"
    BUCKET="$2"

    s3cmd --acl-private \
          --reduced-redundancy \
          "${S3CMD_COMMON_ARGS[@]}" \
          put "$FILE" "$PACO_S3_BUCKET_ROOT/$BUCKET"
}

s3_get()
{
    BUCKET="$1"
    FILE="$2"

    s3cmd "${S3CMD_COMMON_ARGS[@]}" \
          --force \
          get "$PACO_S3_BUCKET_ROOT/$BUCKET" "$FILE"
}

s3_ls()
{
    local P="$1"
    shift

    s3cmd "${S3CMD_COMMON_ARGS[@]}" \
          ls "$PACO_S3_BUCKET_ROOT/$P" \
          "$@" \
        | sed "s|$PACO_S3_BUCKET_ROOT/||"
}

s3_info()
{
    s3cmd "${S3CMD_COMMON_ARGS[@]}" \
          info "$PACO_S3_BUCKET_ROOT/$1" 2>/dev/null
}

s3_rm()
{
    s3cmd "${S3CMD_COMMON_ARGS[@]}" \
          rm "$PACO_S3_BUCKET_ROOT/$1"
}
