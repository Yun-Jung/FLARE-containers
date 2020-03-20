FROM ubuntu:18.04

# Install Dependencies
RUN apt-get update && \
    apt-get install -y \
        git \
        software-properties-common \
        gnupg

# Install yq YAML parser
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && \
    add-apt-repository ppa:rmescandon/yq && \
    apt-get update && \
	apt-get install -y yq