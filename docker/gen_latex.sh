#! /bin/bash

docker_tag="env_latex:latest"
script_name=$(basename "$0")
script_dir=$(dirname "$(realpath "$0")")

read -rd '' help_message << EOM
Usage: $script_name [OPTIONS] COMMAND

Generate latex document.
Run pdflatex with COMMAND in env_latex docker.

Options:
-h, --help
    Show this help message.
EOM

function show_help() {
    echo "$help_message"
    exit 0
}

if [[ $# == 0 || "$1" = "--help" || "$1" = "-h" ]]; then
    show_help
fi

command=$*

"${script_dir}/run_in_env.sh" \
    --docker-tag "${docker_tag}" \
    --mount "$(pwd)" \
    pdflatex "${command}"
