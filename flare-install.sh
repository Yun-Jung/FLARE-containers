#!/bin/bash

source flare-install.conf

sudo apt -y install wget

# Setup Flare Directory on the Host
sudo mkdir -p /opt/flare/shared
sudo chown -R $USER:$USER /opt/flare

# Get Required Files
sudo wget -O /usr/bin/yq $YQ_EXEC
wget -O /opt/flare/shared/flare-config.yml $FLARE_CONFIG
wget -O /opt/flare/flare-host.sh $FLARE_HOST
sudo chmod +x /usr/bin/yq /opt/flare/flare-host.sh

