#!/bin/bash

set -e

if [ -z "$1" ]; then
   echo "Usage: $0 file"
   exit
fi

path=$1

docker rm -f hack-nginx &>/dev/null || true

IMAGE=nginx
IMAGE=k8s.gcr.io/ingress-nginx/controller:v0.41.0

docker run --rm --name hack-nginx -p 8080:80 \
   -v $(pwd)/$path:/etc/nginx/nginx.conf:ro \
   $IMAGE \
   nginx -g 'daemon off;'
