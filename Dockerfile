FROM ubuntu:18.04

# Install Dependencies
RUN apt-get update && \
	apt-get install -y git

# Install yq YAML Parser
RUN wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64

# Get flare-container.sh
RUN wget -c -O /root/flare/flare-container.sh https://raw.githubusercontent.com/careylabvt/flare-containers/flare-push-test/flare-container.sh
RUN chmod +x /root/flare/flare-container.sh