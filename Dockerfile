FROM rocker/tidyverse:4.0.3

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
	vim  \
	libnetcdf-dev \
	libjq-dev \
	libudunits2-dev \
	libnode-dev \
	libgd-dev && \
	R -e "install.packages(c('yaml', 'remotes', 'imputeTS', 'rMR', 'stinepack'), repos = 'https://cloud.r-project.org')" && \
	R -e "remotes::install_github('rqthomas/noaaGEFSpoint@c3ab33cbfab141b49cf52b415c0a1a0fe07d275e')" && \
	R -e "remotes::install_github('eco4cast/EFIstandards@bf5aff16c04052fe50c14f61eace358f9550925d')" && \
	R -e "remotes::install_github('flare-forecast/flare@ab3c15a94186d6aaa9f42da18c66409839d2a7de')" && \
	wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64

# Copy Files to Container
RUN mkdir -p /root/flare/flare_lake_examples/
COPY flare-container.sh /root/flare/
RUN wget -O /root/flare/main.sh https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/commons/main.sh
RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh
ADD flare_lake_examples/ /root/flare/flare_lake_examples/
