#!/usr/bin/env bash
# This file:
#
#  - Installs FLARE dependancies on the host.
#
# Usage:
#
#  Running on the host:               ./flare-install.sh
#  Running directly from the web:     wget -O - https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/${CONTAINER}/flare-install.sh | /usr/bin/env bash

CONTAINER=flare-download-noaa-dev
YQ_URL=https://github.com/mikefarah/yq/releases/download/3.2.2/yq_linux_amd64
YQ=/usr/bin/yq
CONFIG_URL=https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/${CONTAINER}/flare-config.yml
HOST_SCRIPT_URL=https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/${CONTAINER}/flare-host.sh
MAIN_SCRIPT_URL=https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/${CONTAINER}/main.sh

CONFIG="flare-config.yml"
HOST_SCRIPT="flare-host.sh"
MAIN_SCRIPT="main.sh"
DIRECTORY_HOST="/opt/flare"
DIRECTORY_HOST_SHARED="/opt/flare/shared"

# Setup Flare Directory on the Host
sudo mkdir -p ${DIRECTORY_HOST}/${CONTAINER} ${DIRECTORY_HOST_SHARED}/${CONTAINER}
sudo chown -R $USER:$USER ${DIRECTORY_HOST}

# Get Required Files
sudo wget -O ${YQ} ${YQ_URL}
wget -O ${DIRECTORY_HOST_SHARED}/${CONTAINER}/${CONFIG} ${CONFIG_URL}
wget -O ${DIRECTORY_HOST}/${CONTAINER}/${HOST_SCRIPT} ${HOST_SCRIPT_URL}
wget -O ${DIRECTORY_HOST}/${CONTAINER}/${MAIN_SCRIPT} ${MAIN_SCRIPT_URL}
sudo chmod +x ${YQ} ${DIRECTORY_HOST}/${CONTAINER}/${HOST_SCRIPT}

# Set Default Value for ssh-key.private /home/$USER/.ssh/id_rsa (default for non-root), /root/.ssh/id_rsa (default for root)
yq w -i ${DIRECTORY_HOST_SHARED}/${CONTAINER}/${CONFIG} git.remote.ssh-key-private $(([ $EUID -eq 0 ] && echo "/root/.ssh/id_rsa") || echo "/home/$USER/.ssh/id_rsa")

# Set Default Value for git.remote.user.name and git.remote.user.email from the Host Git Config
yq w -i ${DIRECTORY_HOST_SHARED}/${CONTAINER}/${CONFIG} git.remote.user-name "$(git config --global user.name)"
yq w -i ${DIRECTORY_HOST_SHARED}/${CONTAINER}/${CONFIG} git.remote.user-email "$(git config --global user.email)"
