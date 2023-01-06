#!/usr/bin/env bash

docker_tag="env_lint:latest"
script_name=$(basename "$0")
script_dir=$(dirname "$(realpath "$0")")

read -rd '' help_message << EOM
Usage: $script_name [OPTIONS] [PATH]

Run linters on selected file or directory under PATH.
If no PATH provided - lint current directory.

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

function run_in_env() {
    "${script_dir}/run_in_env.sh" \
        --docker-tag "${docker_tag}" \
        --mount "${script_dir}" \
        --mount "${path}" \
        "$*"
}


if [[ $# -gt 2 ]]; then
    show_help
    exit 1
fi

path="$(pwd)"

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
        if [[ $# != 1 ]]; then
            show_help
            exit 1
        fi
        path="$1"
        break # do not interpret positional arguments
        ;;
    esac
done

print_verbose "docker_tag: ${docker_tag}"
print_verbose "script_name: ${script_name}"
print_verbose "script_dir: ${script_dir}"
print_verbose "path: ${path}"

# shell
# create array from command
# IFS=$'\n' - separate by newlines
# -d ''     - stop read at NULL byte
# -r        - do not interpret backslashes as escape sequences
# -a        - populate array
IFS=$'\n' read -d '' -r -a lint_sh_files < <(find "${path}" -name '*.sh')
if [ "${#lint_sh_files[@]}" -gt 0 ]; then
    print_verbose "linting .sh files: " "${lint_sh_files[@]}"
    run_in_env shellcheck "${lint_sh_files[@]}"
fi

# markdown
IFS=$'\n' read -d '' -r -a lint_md_files < <(find "${path}" -name '*.md')
if [ "${#lint_md_files[@]}" -gt 0 ]; then
    print_verbose "linting .md files: " "${lint_md_files[@]}"
    run_in_env mdl --style "${script_dir}/env_lint/mdl.rb" "${lint_md_files[@]}"
fi

# docker
IFS=$'\n' read -d '' -r -a lint_dockerfiles < <(find "${path}" \
    -name Dockerfile \
    -o -name "*dockerfile*")
if [ "${#lint_dockerfiles[@]}" -gt 0 ]; then
    print_verbose "linting dockerfiles: " "${lint_dockerfiles[@]}"
    run_in_env hadolint "${lint_dockerfiles[@]}"
fi

# latex
IFS=$'\n' read -d '' -r -a lint_latex_files < <(find "${path}" -name '*.tex')
if [ "${#lint_latex_files[@]}" -gt 0 ]; then
    print_verbose "linting latex files: " "${lint_latex_files[@]}"
    run_in_env lacheck "${lint_latex_files[@]}"
    run_in_env chktex --localrc "${script_dir}/env_lint/chktexrc" "${lint_latex_files[@]}"
fi

# python
IFS=$'\n' read -d '' -r -a lint_py_files < <(find "${path}" -name '*.py')
if [ "${#lint_py_files[@]}" -gt 0 ]; then
    print_verbose "linting py files: " "${lint_py_files[@]}"
    run_in_env flake8 "${lint_py_files[@]}"
 	run_in_env PYLINTRC="${script_dir}/env_lint/pylintrc" pylint "${lint_py_files[@]}"
fi

# python requirements.txt
IFS=$'\n' read -d '' -r -a lint_pyreq_files < <(find "${path}" -name '*requirements*txt')
if [ "${#lint_pyreq_files[@]}" -gt 0 ]; then
    print_verbose "linting python requirements.txt files: " "${lint_pyreq_files[@]}"
 	run_in_env "${script_dir}/env_lint/check_requirements_txt.sh" "${lint_pyreq_files[@]}"
fi

# c/c++
IFS=$'\n' read -d '' -r -a lint_cpp_files < <(find "${path}" \
    -name '*.c' \
    -o -name '*.cpp' \
    -o -name '*.h')
if [ "${#lint_cpp_files[@]}" -gt 0 ]; then
    print_verbose "linting c/c++ files: " "${lint_cpp_files[@]}"
 	run_in_env cppcheck "${lint_cpp_files[@]}"
fi
