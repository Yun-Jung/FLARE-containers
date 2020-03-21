#!/bin/bash

# Setup Flare Directory on the Host
sudo mkdir -p /opt/flare
sudo chown -R $USER:$USER /opt/flare

# Get Required Files
wget -c -O /opt/flare/flare-config.yml https://raw.githubusercontent.com/CareyLabVT/FLARE-containers/flare-push-test/flare-config.yml
wget -c -O /opt/flare/flare-host.sh https://raw.githubusercontent.com/CareyLabVT/FLARE-containers/flare-push-test/flare-host.sh
chmod +x /opt/flare/flare-host.sh