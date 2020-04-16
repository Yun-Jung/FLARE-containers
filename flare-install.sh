#!/bin/bash

CONTAINER_NAME=flare-external-driver-interface-noaa
YQ_EXEC=https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64
FLARE_CONFIG=https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/flare-external-driver-interface-noaa/flare-config.yml
FLARE_HOST=https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/flare-external-driver-interface-noaa/flare-host.sh
CONFIG_FILE="flare-config.yml"
DIRECTORY_HOST_SHARED="/opt/flare/shared"

# Setup Flare Directory on the Host
sudo mkdir -p /opt/flare/$CONTAINER_NAME /opt/flare/shared/$CONTAINER_NAME
sudo chown -R $USER:$USER /opt/flare

# Get Required Files
sudo wget -O /usr/bin/yq $YQ_EXEC
wget -O /opt/flare/shared/$CONTAINER_NAME/flare-config.yml $FLARE_CONFIG
wget -O /opt/flare/$CONTAINER_NAME/flare-host.sh $FLARE_HOST
sudo chmod +x /usr/bin/yq /opt/flare/$CONTAINER_NAME/flare-host.sh

# Set Default Value for ssh-key.private /home/$USER/.ssh/id_rsa (default for non-root), /root/.ssh/id_rsa (default for root)
yq w -i $DIRECTORY_HOST_SHARED/$CONTAINER_NAME/$CONFIG_FILE ssh-key.private $(([ $EUID -eq 0 ] && echo "/root/.ssh/id_rsa") || echo "/home/$USER/.ssh/id_rsa")

# Set Default Value for git.remote.user.name and git.remote.user.email from the Host Git Config
yq w -i $DIRECTORY_HOST_SHARED/$CONTAINER_NAME/$CONFIG_FILE git.remote.user.name "$(git config --global user.name)"
yq w -i $DIRECTORY_HOST_SHARED/$CONTAINER_NAME/$CONFIG_FILE git.remote.user.email "$(git config --global user.email)"
