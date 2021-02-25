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
	libnetcdf-dev && \
	R -e "install.packages(c('yaml', 'remotes', 'imputeTS', 'rMR'), repos = 'https://cloud.r-project.org')" && \
	R -e "remotes::install_github('rqthomas/noaaGEFSpoint@c3ab33cbfab141b49cf52b415c0a1a0fe07d275e')" && \
	wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64

	# Copy Files to Container
	RUN mkdir -p /root/flare/flare_lake_examples/
	COPY flare-container.sh /root/flare/
	RUN wget https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/master/commons/commons.sh -O /root/flare/commons.sh
	RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh
	ADD flare_lake_examples/ /root/flare/flare_lake_examples/
