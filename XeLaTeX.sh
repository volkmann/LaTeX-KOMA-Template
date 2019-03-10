#!/usr/bin/env bash
#
# TODO: write a comment to describe this script!
# Every file must have a top-level comment including a brief overview of its
# contents. A copyright notice and author information are optional.

# Any function that is not both obvious and short must be commented. Any
# function in a library must be commented regardless of length or complexity.

# TODO(volkmann): write your script (ticket ####)

# Show usage of the script
# Globals:
#   __base
# Arguments:
#   None
# Returns:
#   None
show_usage() {
  cat <<-EOF
  usage: ${BASE} filename
EOF
}

set_shell_options() {
  set -o errexit
  set -o pipefail
#  set -o xtrace
  set -o nounset
#  set -o noexec
}

init_global_parameters() {
  readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  readonly FILE="${DIR}/$(basename "${BASH_SOURCE[0]}")"
  readonly BASE="$(basename ${FILE})"
  readonly ROOT="$(cd "$(dirname "${DIR}")" && pwd)"
}

execute_command() {
  if [[ $# -ne 1  ]]; then
    show_usage
    exit 1
  fi

  local filename="$1"

  if is_file "${filename}.tex"; then
    make_pdf $filename
  else
    echo "${filename}.tex" not found!
    exit 2
  fi
}

make_pdf() {
  local filename="$1"
  local texfile="${filename}.tex"

  xelatex ${texfile}
  makeglossaries ${filename}
  xelatex ${texfile}
  makeglossaries ${filename}
  biber --isbn-normalise *.bcf && makeindex *.idx
  xelatex ${texfile}
  xelatex ${texfile}
}

is_empty() {
  local var=$1

  [[ -z $var  ]]
}

is_not_empty() {
  local var=$1

  [[ -n $var ]]
}

is_file() {
  local file=$1

  [[ -f $file ]]
}

is_dir() {
  local dir=$1

  [[ -d $dir ]]
}

# A function to print out error messages
#
# $@ message to print
write_error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

main() {
  set_shell_options
  init_global_parameters
  execute_command "$@"
}

# if script is usable as library
[[ "$0" == "$BASH_SOURCE" ]] \
  && main "$@"

