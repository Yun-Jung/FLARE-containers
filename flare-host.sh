#!/usr/bin/env bash
# This file:
#
#  - Runs flare-external-driver-interface-noaa container from the host.
#
# Usage:
#
#  LOG_LEVEL=7 ./flare-host.sh -d
#
# Based on a template by BASH3 Boilerplate v2.3.0
# http://bash3boilerplate.sh/#authors
#
# The MIT License (MIT)
# Copyright (c) 2013 Kevin van Zonneveld and contributors
# You are not obligated to bundle the LICENSE file with your b3bp projects as long
# as you leave these references intact in the header comments of your source files.


### BASH3 Boilerplate (b3bp) Header
##############################################################################

# Commandline options. This defines the usage page, and is used to parse cli
# opts & defaults from. The parsing is unforgiving so be precise in your syntax
# - A short option must be preset for every long option; but every short option
#   need not have a long option
# - `--` is respected as the separator between options and arguments
# - We do not bash-expand defaults, so setting '~/app' as a default will not resolve to ${HOME}.
#   you can use bash variables to work around this (so use ${HOME} instead)

# shellcheck disable=SC2034
read -r -d '' __usage <<-'EOF' || true # exits non-zero when EOF encountered
  -v               Enable verbose mode, print script as it is executed
  -d --debug       Enables debug mode
  -h --help        This page
  -n --no-color    Disable color output
EOF

# shellcheck disable=SC2034
read -r -d '' __helptext <<-'EOF' || true # exits non-zero when EOF encountered
  'flare-host' script for 'flare-external-driver-interface-noaa' container
EOF

# shellcheck source=main.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/main.sh"


### Signal trapping and backtracing
##############################################################################

function __b3bp_cleanup_before_exit () {
  info "Done Cleaning Up"
}
trap __b3bp_cleanup_before_exit EXIT

# requires `set -o errtrace`
__b3bp_err_report() {
  local error_code=${?}
  # shellcheck disable=SC2154
  error "Error in ${__file} in function ${1} on line ${2}"
  exit ${error_code}
}
# Uncomment the following line for always providing an error backtrace
# trap '__b3bp_err_report "${FUNCNAME:-.}" ${LINENO}' ERR


### Command-line argument switches (like -d for debugmode, -h for showing helppage)
##############################################################################

# debug mode
if [[ "${arg_d:?}" = "1" ]]; then
  set -o xtrace
  PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
  LOG_LEVEL="7"
  # Enable error backtracing
  trap '__b3bp_err_report "${FUNCNAME:-.}" ${LINENO}' ERR
fi

# verbose mode
if [[ "${arg_v:?}" = "1" ]]; then
  set -o verbose
fi

# no color mode
if [[ "${arg_n:?}" = "1" ]]; then
  NO_COLOR="true"
fi

# help mode
if [[ "${arg_h:?}" = "1" ]]; then
  # Help exists with code 1
  help "Help using ${0}"
fi


### User-defined and Runtime
##############################################################################

CONTAINER="flare-external-driver-interface-noaa-dev"

SSHKEY_PRIVATE_GENERAL=$(yq r ${DIRECTORY_HOST_SHARED}/${CONTAINER}/${CONFIG} ssh-key.private)
SSHKEY_PRIVATE_CONTAINER=$(yq r ${DIRECTORY_HOST_SHARED}/${CONTAINER}/${CONFIG} ${CONTAINER}.git.ssh-key.private)
SSHKEY_PRIVATE=$(set_value ${SSHKEY_PRIVATE_CONTAINER} ${SSHKEY_PRIVATE_GENERAL})

cp -u ${SSHKEY_PRIVATE} ${DIRECTORY_HOST_SHARED}/${CONTAINER}

DOCKER_RUN_COMMAND="docker run -v ${DIRECTORY_HOST_SHARED}/${CONTAINER}:${DIRECTORY_CONTAINER_SHARED} ${DOCKERHUB_ID}/${CONTAINER} ${DIRECTORY_CONTAINER}/${CONTAINER_SCRIPT}"

# Run Docker Container
${DOCKER_RUN_COMMAND}
