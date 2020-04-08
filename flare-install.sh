#!/bin/bash

CONTAINER_NAME=flare-external-driver-interface-noaa
YQ_EXEC=https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64
FLARE_CONFIG=https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/flare-external-driver-interface-noaa/flare-config.yml
FLARE_HOST=https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/flare-external-driver-interface-noaa/flare-host.sh

sudo apt -y install wget \
					curl

curl -sSL https://get.docker.com/ | sudo sh

# Setup Flare Directory on the Host
sudo mkdir -p /opt/flare/shared/$CONTAINER_NAME
sudo chown -R $USER:$USER /opt/flare

# Get Required Files
sudo wget -O /usr/bin/yq $YQ_EXEC
wget -O /opt/flare/shared/$CONTAINER_NAME/flare-config.yml $FLARE_CONFIG
wget -O /opt/flare/$CONTAINER_NAME/flare-host.sh $FLARE_HOST
sudo chmod +x /usr/bin/yq /opt/flare/$CONTAINER_NAME/flare-host.sh
