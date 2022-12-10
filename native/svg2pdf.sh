#! /bin/bash

script_name="$(basename "$0")"

read -rd '' help_message << EOM
Usage: $script_name INPUT_FILE_SVG OUTPUT_FILE_PDF

Convert .svg file to .pdf.

Options:
    -h, --help      Show this help message.
EOM

function show_help() {
    echo "$help_message"
    exit 0
}

if [ $# != 2 ]; then
    show_help
fi

# without DISPLAY='' inkscape still tries to open GUI even with
# `--without-gui` option
#
# can also try to add `--export-latex` but I see no difference
#
# running inkscape in docker/wsl produces several useless warnings,
# suppressing those at the end
DISPLAY='' inkscape \
    "$1" \
    --export-pdf="$2" \
    --export-area-drawing \
    2>/dev/null

echo "done"
