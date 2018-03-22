#!/bin/bash

S3_CONFIG=$(dirname "${BASH_SOURCE[0]}")/s3-credentials.conf
PACO_S3_BUCKET_ROOT="s3://cpp-packages/paco"

s3_put()
{
    FILE="$1"
    BUCKET="$2"
    
    s3cmd --acl-private \
          --reduced-redundancy \
          --config="$S3_CONFIG" \
          put "$FILE" "$PACO_S3_BUCKET_ROOT/$BUCKET"
}

s3_get()
{
    BUCKET="$1"
    FILE="$2"
    
    s3cmd --config="$S3_CONFIG" \
          get "$PACO_S3_BUCKET_ROOT/$BUCKET" "$FILE"
}

s3_ls()
{
    s3cmd --config="$S3_CONFIG" \
          ls "$PACO_S3_BUCKET_ROOT/$1"
}

s3_rm()
{
    s3cmd --config="$S3_CONFIG" \
          rm "$PACO_S3_BUCKET_ROOT/$1"
}
