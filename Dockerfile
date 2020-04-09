FROM rocker/rstudio

# Install Dependencies
RUN apt-get -yq update && \
	apt-get -yqq install wget \
	git \
	libxml2-dev \
	ssh

# Install R Packages
RUN R -e "install.packages('rNOMADS')" && \
	R -e "install.packages('RCurl')" && \
	R -e "install.packages('stringr')" && \
	R -e "install.packages('yaml')"

RUN mkdir /root/flare

# Install yq YAML Parser
RUN wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64

# Get flare-container.sh
RUN wget -O /root/flare/flare-container.sh https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/flare-external-driver-interface-noaa/flare-container.sh

# Get NOAA Downloader Script
RUN wget -O /root/flare/grab-weekly-forecast-for-glm-v3.R https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/flare-external-driver-interface-noaa/grab-weekly-forecast-for-glm-v3.R

RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh
