#! /bin/bash

script_name="$(basename "$0")"

read -rd '' help_message << EOM
Usage: $script_name [OPTIONS] REQUIREMENTS_TXT

Check that REQUIREMENTS_TXT file has versions set for every module.

Options:
    -h, --help      Show this help message.
EOM

function show_help() {
    echo "$help_message"
    exit 0
}

if [ $# = 0 ]; then
    show_help
fi

# parse script arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -h|--help)
        show_help
        shift # parse next value
        ;;
    *)
        break # do not interpret positional arguments
        ;;
    esac
done

while [[ $# -gt 0 ]]; do
    path="$1"

    if [ -f "$path" ]; then
        if grep -v "[a-zA-Z0-9]*=[a-zA-Z0-9]*" "$path" ; then
            echo "$path has at least one component without version"
            exit 1
        fi
    fi
    shift
done
