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