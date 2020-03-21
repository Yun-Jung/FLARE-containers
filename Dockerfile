FROM ubuntu:18.04

# Install Dependencies
RUN apt-get update && \
	apt-get install -y wget \
	git

RUN mkdir /root/flare

# Install yq YAML Parser
RUN wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64

# Get flare-container.sh
RUN wget -O /root/flare/flare-container.sh https://raw.githubusercontent.com/CareyLabVT/FLARE-containers/flare-push-test/flare-container.sh

RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh