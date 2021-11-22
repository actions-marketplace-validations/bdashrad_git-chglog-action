#!/usr/bin/env sh

set -o errexit
set -o nounset
set -o pipefail

DEFAULT_GIT_CHGLOG_VERSION=0.15.0
DEFAULT_GIT_CHGLOG_CONFIG="./.chglog"

cd "/github/workspace/" || exit 1

pwd

show_help() {
cat << EOF
Usage: $(basename "$0") <options>
    -h          Display help
    -c          Config file
    -n          Next tag version
    -o          Output file
    -t          Tag
    -v          The git-chglog version to use (default: $DEFAULT_GIT_CHGLOG_VERSION)"
    -r          Git repository (default: $DEFAULT_GIT_REPOSITORY_URL)"
EOF
}

main() {
  local version="$DEFAULT_GIT_CHGLOG_VERSION"
  local config="$DEFAULT_GIT_CHGLOG_CONFIG"
  local next_tag=
  local output=
  local tag=

  parse_command_line "$@"

  install_git_chglog

  run_git_chglog 
}

parse_command_line() {
  while getopts ":n:c:o:t:v:h" opt; do
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
        echo "::debug ::config: $config"
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
  echo "Installing git-chglog..."
  wget -O git-chglog.tar.gz \
    https://github.com/git-chglog/git-chglog/releases/download/v${version}/git-chglog_${version}_linux_amd64.tar.gz
  tar -xzf git-chglog.tar.gz -C /usr/local/bin/
  chmod 755 /usr/local/bin/git-chglog
  rm -f git-chglog.tar.gz

  git-chglog --version
}

run_git_chglog() {
  pwd
  if [ -f "${config}/config.yml" ] && [ -f "${config}/CHANGELOG.tpl.md" ]; then
    echo "::debug ::git-chlog: -c '${config}'"
    echo "::debug ::git-chlog: -n '${next_tag}'"
    echo "::debug ::git-chlog: -o '${output}'"
    echo "::debug ::git-chlog: -t '${tag}'"
    echo "::debug ::git-chlog: -v '${version}'"
    echo "::info ::git-chlog executing command: /usr/local/bin/git-chglog --config "${config}/config.yml" ${next_tag} ${tag}"

    changelog=$(/usr/local/bin/git-chglog --config "${config}/config.yml" ${next_tag} ${tag})

    echo "----------------------------------------------------------"
    echo "${changelog}"
    echo "----------------------------------------------------------"

    echo "::debug ::git-chlog: -o '${output}'"
    if [[ ! -z "$output" ]]; then
      echo "::debug ::git-chlog -o options is set. writing changelog to ${output}"
      echo "${changelog}" > ${output}
    fi

    echo "::set-output name=changelog::$( echo "$changelog" | jq -sRr @uri )"

  else 
    echo "::warning ::git-chlog configuration was not found, skipping changelog generation."
  fi
}

main "$@"