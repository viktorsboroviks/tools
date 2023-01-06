#! /bin/bash

script_name=$(basename "$0")
script_dir=$(dirname "$(realpath "$0")")

read -rd '' help_message << EOM
Usage: $script_name [OPTIONS]

Remove dangling Docker images.

Options:
-h, --help
    Show this help message.

-v, --verbose
    Print verbose debug messages.
EOM

function show_help() {
    echo "$help_message"
}

function print_verbose() {
    [ "$verbose" ] && echo "$script_name:> $*"
}

# parse script arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--verbose)
        verbose=1
        print_verbose "verbose debug enabled"
        shift # parse next value
        ;;
    *)
        show_help
        exit 1
        break # do not interpret positional arguments
        ;;
    esac
done

print_verbose "script_name: ${script_name}"
print_verbose "script_dir: ${script_dir}"

if [ -z "$(which docker)" ]; then
    echo "docker not found" >&2
    exit 0
fi

IFS=$'\n' read -d '' -r -a docker_rm_images < <(docker images --filter "dangling=true" -q)
if [ "${#docker_rm_images[@]}" -eq 0 ]; then
    echo "no dangling docker images found" >&2
    exit 0
fi

print_verbose "deleting docker images..."
docker rmi --force "${docker_rm_images[@]}"
