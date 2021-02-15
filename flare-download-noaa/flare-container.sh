#!/usr/bin/env bash
# This file:
#
#  - Runs the service inside FLARE container.
#
# Usage:
#
#  LOG_LEVEL=7 ./flare-container.sh -d
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
  -o --openwhisk   Enables OpenWhisk mode
EOF

# shellcheck disable=SC2034
read -r -d '' __helptext <<-'EOF' || true # exits non-zero when EOF encountered
  'flare-container' script for '${CONTAINER_NAME}' container
EOF

# shellcheck source=main.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/main.sh"


### Signal trapping and backtracing
##############################################################################

function __b3bp_cleanup_before_exit () {
  rm -rf /root/.ssh
  info "Done Cleaning Up Container"
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

# OpenWhisk mode
if [[ "${arg_o:?}" = "1" ]]; then
  echo "Running in OpenWhisk Mode..."
fi


### User-defined and Runtime
##############################################################################

RSCRIPT="launch_download_downscale.R"
CONTAINER_NAME=${1}
GIT_REMOTE_USERNAME=$(yq r ${DIRECTORY_CONTAINER_SHARED}/${CONTAINER_NAME}/${CONFIG_FILE} git.remote.user-name)
GIT_REMOTE_USEREMAIL=$(yq r ${DIRECTORY_CONTAINER_SHARED}/${CONTAINER_NAME}/${CONFIG_FILE} git.remote.user-email)
GIT_REMOTE_SSHKEYPRIVATE=$(yq r ${DIRECTORY_CONTAINER_SHARED}/${CONTAINER_NAME}/${CONFIG_FILE} git.remote.ssh-key-private)

# Extract Private SSH Key File Name from Full Path
GIT_REMOTE_SSHKEYPRIVATE_FILE=$(awk -F/ '{print $NF}' <<< ${GIT_REMOTE_SSHKEYPRIVATE})

# Setup SSH
mkdir -p /root/.ssh
cp -u ${DIRECTORY_CONTAINER_SHARED}/${CONTAINER_NAME}/${GIT_REMOTE_SSHKEYPRIVATE_FILE} /root/.ssh/id_rsa

# Setup Git
git config --global user.name ${GIT_REMOTE_USERNAME}
git config --global user.email ${GIT_REMOTE_USEREMAIL}

# Run R Script
# Pass `${CONTAINER_NAME}` Argument to the R Script
Rscript ${DIRECTORY_CONTAINER}/${RSCRIPTS_DIRECTORY}/${RSCRIPT} ${CONTAINER_NAME}

# Create Date Variables
TODAY_DATE=$(date +%Y-%m-%d)
END_DATE=$(date --date="+16 day" +%Y-%m-%d)

# Create Path Variables
FOLDER=${DIRECTORY_HOST_SHARED}/${CONTAINER_NAME}/NOAAGEFS_6hr/fcre/${TODAY_DATE}
FOLDER_00=${DIRECTORY_HOST_SHARED}/${CONTAINER_NAME}/NOAAGEFS_6hr/fcre/${TODAY_DATE}/00
FOLDER_06=${DIRECTORY_HOST_SHARED}/${CONTAINER_NAME}/NOAAGEFS_6hr/fcre/${TODAY_DATE}/06
FOLDER_12=${DIRECTORY_HOST_SHARED}/${CONTAINER_NAME}/NOAAGEFS_6hr/fcre/${TODAY_DATE}/12
FOLDER_18=${DIRECTORY_HOST_SHARED}/${CONTAINER_NAME}/NOAAGEFS_6hr/fcre/${TODAY_DATE}/18

TRIGGER_FILE=${DIRECTORY_HOST_SHARED}/${CONTAINER_NAME}/NOAAGEFS_6hr/fcre/${TODAY_DATE}/trigger.txt
WRITE_TRIGGER=true

if [ ! -f "$TRIGGER_FILE" ]; then
    echo "Not triggered."
    if [ -d "FOLDER_00" -a -d "FOLDER_06" -a -d "FOLDER_12" -a -d "FOLDER_18"]; then
        echo "All Folders exist."
        for time in 00 06 12 18
        do
          echo "time: $time"
          for i in {0..9}
          do
            FILE=${FOLDER}/${time}/NOAAGEFS_6hr_fcre_${TODAY_DATE}T${time}_${END_DATE}T${time}_ens0${i}.nc
            if [ ! -f "$FILE" ]; then
              echo "$FILE does not exist."
              WRITE_TRIGGER=false
              break
            fi
          done
          for i in {10..30}
          do
            FILE=${FOLDER}/${time}/NOAAGEFS_6hr_fcre_${TODAY_DATE}T${time}_${END_DATE}T${time}_ens${i}.nc
            if [ ! -f "$FILE" ]; then
              echo "$FILE does not exist."
              WRITE_TRIGGER=false
              break
            fi
          done
        done
        if [ "$WRITE_TRIGGER" = true ] ; then
          echo "Triggered" > trigger.txt
          curl -u $AUTH https://$APIHOST/api/v1/namespaces/_/triggers/flare-download-noaa-ready-fire -X POST -H "Content-Type: application/json"
        fi
    fi
fi
