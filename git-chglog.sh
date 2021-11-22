DEFAULT_GIT_CHGLOG_VERSION=v0.15.0

show_help() {
cat << EOF
Usage: $(basename "$0") <options>
    -h          Display help
    -c          Config file
    -n          Next tag version
    -o          Output file
    -t          Tag
    -v          The git-chglog version to use (default: $DEFAULT_GIT_CHGLOG_VERSION)"
EOF
}

main() {
    local version="$DEFAULT_GIT_CHGLOG_VERSION"

    parse_command_line "$@"

    install_git_chglog
}

parse_command_line() {
  if [ $OPTIND -eq 1 ]; then
    # No options were passed
    echo "No options were passed."
    show_help
    exit 1
  fi
  while getopts ":n:c:o:t:h" opt; do
    case ${opt} in
      h)
        show_help
        exit 0
        ;;
      c )
        if [ -z "${OPTARG}" ]; then
          echo "::error ::git-chlog path is not set using flag '-c <configuration directory>'"
          exit 1
        fi
        config=$OPTARG
        ;;
      n )
        if [ ! -z ${OPTARG} ]; then
          next_tag="--next-tag ${OPTARG}"
        fi
        ;;
      o )
        if [ ! -z ${OPTARG} ]; then
          output="${OPTARG}"
        fi
        ;;
      t )
        tag="${OPTARG}"
        ;;
      v )
        version="${OPTARG}"
        ;;
      * )
        show_help
        exit 1
        ;;
    esac
  done
  shift $((OPTIND -1))
}

install_git_chglog() {
    if [[ ! -d "$RUNNER_TOOL_CACHE" ]]; then
        echo "Cache directory '$RUNNER_TOOL_CACHE' does not exist" >&2
        exit 1
    fi

    local arch
    arch=$(uname -m)
    local cache_dir="$RUNNER_TOOL_CACHE/gchglog/$version/$arch"
    local venv_dir="$cache_dir/venv"

    if [[ ! -d "$cache_dir" ]]; then
        mkdir -p "$cache_dir"

        echo "Installing chart-testing..."
        curl -sSLo ct.tar.gz "https://github.com/helm/chart-testing/releases/download/$version/chart-testing_${version#v}_linux_amd64.tar.gz"
        tar -xzf ct.tar.gz -C "$cache_dir"
        rm -f ct.tar.gz

        echo 'Creating virtual Python environment...'
        python3 -m venv "$venv_dir"

        echo 'Activating virtual environment...'
        # shellcheck disable=SC1090
        source "$venv_dir/bin/activate"

        echo 'Installing yamllint...'
        pip3 install yamllint==1.25.0

        echo 'Installing Yamale...'
        pip3 install yamale==3.0.4
    fi

    # https://github.com/helm/chart-testing-action/issues/62
    echo 'Adding ct directory to PATH...'
    echo "$cache_dir" >> "$GITHUB_PATH"

    echo 'Setting CT_CONFIG_DIR...'
    echo "CT_CONFIG_DIR=$cache_dir/etc" >> "$GITHUB_ENV"

    echo 'Configuring environment variables for virtual environment for subsequent workflow steps...'
    echo "VIRTUAL_ENV=$venv_dir" >> "$GITHUB_ENV"
    echo "$venv_dir/bin" >> "$GITHUB_PATH"

    "$cache_dir/ct" version
}

main "$@"