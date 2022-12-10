#! /bin/bash

script_name=$(basename "$0")
docker_tag=
auto_mount=
verbose=

read -rd '' help_message << EOM
Usage: $script_name [OPTIONS] DOCKER_TAG COMMAND

Run COMMAND in Docker.
- All COMMAND input and output files are mounted from the Host under the same
user and paths.
- Current working directory is also Docker's working directory.

Options:
-a, --auto-mount
    Automatically mount all directory paths from the COMMAND and its
    parameters.
    This is useful when you want to execute the local script in a Docker
    environment.
    This way Docker backend becomes transparent to the user.
    See \`Example\` section at the bottom.
    Can be combined with \`-m\` to mount additional directories.

-d, --docker-tag
    Docker tag to be used.

-h, --help
    Show this help message.

-m, --mount dir
-m, --mount dir1,dir2
    List of directories from the Host to be mounted to Docker.
    All directories that are not mounted to Docker are not visible for it.
    By default only current working directory is mounted.

-v, --verbose
    Print verbose debug messages.

Examples:
./path/$script_name -a ./path/clone-build-trident.sh release-30400101 ~/my_dir

cd ~/my_dir/raptor_release-30400101/vfraptor-setup/build
~/path/$script_name -m .. -a ~/scripts/bitbake-rebuild.sh secins
EOM

function show_help() {
	echo "$help_message"
	exit 0
}

function print_verbose() {
    [ "$verbose" ] && echo "$script_name:> $*"
}

if [ $# = 0 ]; then
    show_help
fi

# parse script arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -a|--auto-mount)
        auto_mount=1
        shift # parse next value
        ;;
    -d|--docker-tag)
        docker_tag=$2
        shift # parse next value
        shift
        ;;
    -h|--help)
        show_help
        shift # parse next value
        ;;
    -m|--mount)
        mount_arguments="$mount_arguments $2"
        shift # parse next value
        shift
        ;;
    -e|--env)
        env_arguments="$env_arguments $2"
        shift # parse next value
        shift
        ;;
    -v|--verbose)
        verbose=1
        shift # parse next value
        ;;
    *)
        command=$*
        print_verbose "command: $command"
        break # do not interpret positional arguments
        ;;
    esac
done

# generate list of mount volumes
mount_volumes=("$PWD")
IFS=" "
for mount in $mount_arguments; do
    # replace '~' with '$HOME' so it can be interpreted
    mount="${mount/#\~/$HOME}"
    # only add mount to the list if it is an existing directory on Host
    if [ -d "$mount" ]; then
        mount_volumes+=("$(readlink -f "$mount")")
    fi
done

# add automatically generated mounts
if [ $auto_mount ]; then
    print_verbose "adding automatically generated mounts..."
    while [[ $# -gt 0 ]]; do
        # if positional argument is a file on Host - add path to it's directory
        if [ -f "$1" ]; then
            mount_volumes+=("$(dirname "$(readlink -f "$1")")")
        # if positional argument is a directory on Host - add it
        elif [ -d "$1" ]; then
            mount_volumes+=("$(readlink -f "$1")")
        fi
    shift
    done
fi
print_verbose "mount volumes: ${mount_volumes[*]}"

# convert list of volumes to Docker arguments
docker_mount_arguments=()
IFS=","
for mount_path in "${mount_volumes[@]}"; do
    docker_mount_arguments+=("--volume=$mount_path:$mount_path")
done
print_verbose "mount arguments: ${docker_mount_arguments[*]}"

# convert list of envars to Docker arguments
docker_env_arguments=()
IFS=" "
for env in $env_arguments; do
    docker_env_arguments+=("--env $env")
done
print_verbose "env arguments: ${docker_env_arguments[*]}"

print_verbose "running command in Docker..."

# shellcheck disable=SC2068
# volumes with config files are explicitly mounted after the
# $docker_mount_arguments to always override those
docker run \
    --rm \
    ${docker_mount_arguments[@]} \
    ${docker_env_arguments[@]} \
    --workdir "$PWD" \
    "$docker_tag" \
    "$command"
