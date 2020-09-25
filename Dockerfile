FROM rocker/tidyverse:4.0.0-ubuntu18.04

# Set Environment Variables
ENV TZ=America/New_York
ARG DEBIAN_FRONTEND=noninteractive

# Install Dependencies
RUN apt-get -yq update && \
	apt-get -yqq install wget \
	git \
	libxml2-dev \
	libcurl4-openssl-dev \
	libssl-dev \
	ssh \
	tzdata \
	vim  && \
	R -e "install.packages(c('yaml', 'remotes'), repos = 'https://cloud.r-project.org')" && \
	R -e "remotes::install_github('rqthomas/noaaGEFSpoint')" && \
	wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.3.2/yq_linux_amd64

# Copy Files to Container
RUN mkdir -p /root/flare/fcre
COPY flare-container.sh /root/flare/
RUN wget -O /root/flare/main.sh https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/commons/main.sh
RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh
ADD fcre /root/flare/fcre/
