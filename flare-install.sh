#!/bin/bash

# Setup Flare Directory on the Host
sudo mkdir -p /opt/flare/shared
sudo chown -R $USER:$USER /opt/flare

# Get Required Files
sudo wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64
wget -O /opt/flare/shared/flare-config.yml https://raw.githubusercontent.com/CareyLabVT/FLARE-containers/flare-push-test/flare-config.yml
wget -O /opt/flare/flare-host.sh https://raw.githubusercontent.com/CareyLabVT/FLARE-containers/flare-push-test/flare-host.sh
sudo chmod +x /usr/bin/yq /opt/flare/flare-host.sh
