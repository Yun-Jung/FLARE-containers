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
	R -e "remotes::install_github('FLARE-forecast/noaaGEFSpoint@fc08f6272da5b7bdeec3b764050e490482d27240')" && \
	R -e "remotes::install_github('eco4cast/EFIstandards@bf5aff16c04052fe50c14f61eace358f9550925d')" && \
	R -e "remotes::install_github('FLARE-forecast/flare@368da65c3df396570c71b8072fe3fcb5ab0ea9fa')" && \
	wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64

# Copy Files to Container
RUN mkdir -p /root/flare/flare_lake_examples/
COPY flare-container.sh /root/flare/
RUN wget https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/master/commons/commons.sh -O /root/flare/commons.sh
RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh
ADD flare_lake_examples/ /root/flare/flare_lake_examples/
