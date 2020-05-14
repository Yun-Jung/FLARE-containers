FROM rocker/r-base

# Install Dependencies
RUN apt-get -yq update && \
	apt-get -yqq install wget \
	git \
	libxml2-dev \
	libcurl4-openssl-dev \
	libssl-dev \
	ssh && \
	R -e "install.packages(c('rNOMADS', 'RCurl', 'stringr', 'yaml'))" && \
	wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64 

# Get flare-container.sh
RUN mkdir /root/flare && \
	wget -O /root/flare/flare-container.sh https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/flare-external-driver-interface-noaa-dev/flare-container.sh && \
	wget -O /root/flare/main.sh https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/flare-external-driver-interface-noaa-dev/main.sh && \
	chmod +x /usr/bin/yq /root/flare/flare-container.sh

# Get NOAA Downloader Script
RUN wget -O /root/flare/grab-weekly-forecast-for-glm-v3.R https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/flare-external-driver-interface-noaa-dev/grab-weekly-forecast-for-glm-v3.R
