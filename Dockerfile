FROM rocker/tidyverse:3.6.3-ubuntu18.04

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
	R -e "install.packages('https://r-forge.r-project.org/scm/viewvc.php/*checkout*/trunk/rNOMADS/rNOMADS_2.5.0.tar.gz?revision=102&root=rnomads', repos = NULL, type ='source')" && \
	R -e "install.packages(c('RCurl', 'stringr', 'yaml'))" && \
	wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.3.2/yq_linux_amd64

# Copy Files to Container
RUN mkdir -p /root/flare/r-script/
COPY flare-container.sh main.sh /root/flare/
RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh
COPY r-script/grab-weekly-forecast-for-glm-v3.R /root/flare/r-script/
