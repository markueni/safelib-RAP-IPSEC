#!/bin/bash

# Based on github.com/piotr-roslaniec/rust-sdk-helper

IMAGE=ocet/docker-sgx:latest
SRC=$(pwd)
DIR=$(basename $SRC)
CONTAINER=sgx-sdk-$DIR

usage() {
    cat <<EOF
usage: $0 options
Set up Docker container with Intel SGX SDK.
OPTIONS:
   -h, --help    Show this message
   -r, --run     Create/recreate container and attach
   -a, --attach  Attach shell to existing container
   -k, --kill    Kill container if exists
EOF
}

run() {
    ls /dev/isgx >/dev/null &>/dev/null || {
        echo "SGX Driver NOT installed"
        exit 1
    }

    kill

    docker run -d -it -v $SRC:/usr/src/app:rw --device /dev/isgx --name $CONTAINER $IMAGE /bin/bash
    docker port $CONTAINER

    attach
}

attach() {
    docker exec -it $CONTAINER bash
}

kill() {
    docker rm -f $CONTAINER &>/dev/null && echo 'Removed old container'
}

while test $# -gt 0; do
    case "$1" in
    -h | --help)
        usage
        exit 1
        ;;
    -r | --run)
        shift
        run
        exit 0
        ;;
    -a | --attach)
        shift
        attach
        exit 0
        ;;
    -k | --kill)
        shift
        kill
        exit 0
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done
