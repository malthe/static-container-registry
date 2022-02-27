#!/bin/bash

image=${1:-$IMAGE}
tag=${2:-$TAG}

sha() {
  sha256sum $1 | cut -d" " -f1
}

upload() {
  key=v2/$image/$2
  dest=s3://$BUCKET/$key
  aws $ENDPOINT s3api head-object --bucket $BUCKET --key "$key" > /dev/null 2>&1 || \
  aws s3 $ENDPOINT cp "$1" "$dest" --acl public-read --content-type $3
}

find blobs/sha256 -type f | while read source; do
  dest=`sed 's/\(.*\)\//\1:/' <<< $source`
  content_type=$(jq -reM .config.mediaType < $source 2>/dev/null)
  upload "$source" "$dest" ${content_type:-binary/octet-stream}
done

upload index.json "manifests/$tag" application/vnd.docker.distribution.manifest.list.v2+json
upload index.json "manifests/sha256:`sha index.json`" application/vnd.docker.distribution.manifest.list.v2+json
