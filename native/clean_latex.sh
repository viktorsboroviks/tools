#! /bin/bash

script_name=$(basename "$0")

read -rd '' help_message << EOM
Usage: $script_name [OPTIONS] PATH

Remove temporary latex files from PATH.

Options:
-h, --help              Show this help message.
-v, --verbose           Enable verbose messages.

Examples:
./${script_name} my/dir
EOM

function show_help() {
    # without the \" all newline characters would be ignored
    echo "$help_message"
    exit 0
}

function print_verbose() {
    [ "$verbose" ] && echo "$script_name:> $*"
}

if [ $# -eq 0 ] || [ $# -gt 2 ]; then
    show_help
fi

# parse script arguments
while [ $# -gt 0 ]; do
    key="$1"

    case $key in
    -h|--help)
        show_help
        shift # parse next value
        ;;
    -v|--verbose)
        verbose=1
        verbose_flag="-v"
        shift # parse next value
        ;;
    *)
        path=$*
        print_verbose "path: $path"
        break # do not interpret positional arguments
        ;;
    esac
done

# remove latex temporary files (except for .pdf)
# shellcheck disable=SC2046
rm -rf ${verbose_flag} $(find "${path}"/ \
    -name '*.aux' \
    -o -name '*.bbl' \
    -o -name '*.bl' \
    -o -name '*.blg' \
    -o -name '*.fdb_latexmk' \
    -o -name '*.fls' \
    -o -name '*.hst' \
    -o -name '*.log' \
    -o -name '*.out' \
    -o -name '*.synctex.gz' \
    -o -name '*.toc' \
    -o -name '*.ver' \
)
