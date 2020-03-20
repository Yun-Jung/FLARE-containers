#!/bin/bash

# Setup flare directory
sudo mkdir -p /opt/flare
sudo chown -R $USER:$USER /opt/flare

# Download required files
wget -c -O /opt/flare/flare-config.yml https://raw.githubusercontent.com/careylabvt/flare-containers/flare-push-test/flare-config.yml
wget -c -O /opt/flare/flare-host.sh https://raw.githubusercontent.com/caeylabvt/flare-containers/flare-push-test/flare-host.sh
wget -c -O /opt/flare/flare-container.sh https://raw.githubusercontent.com/careylabvt/flare-containers/flare-push-test/flare-container.sh

# Add execution permission to scripts
chmod +x /opt/flare/*.sh
