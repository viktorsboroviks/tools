#! /bin/bash

script_name=$(basename "$0")

read -rd '' help_message << EOM
Usage: $script_name PATH DOCKER_TAG

Setup the finance environment.

Mandatory arguments:
PATH
    Path to directory with Dockerfile and other depencencies.

DOKER_TAG
    Docker tag to be used.
EOM

function show_help() {
    echo "$help_message"
    exit 0
}

function print_script() {
    echo "$script_name:> $*"
}

if [[ $# -ne 2 ]]; then
    show_help
fi

docker_path="$1"
docker_tag="$2"

docker build \
    --tag "$docker_tag" \
    "$docker_path"
