FROM rocker/geospatial:4.0.3

# Set Environment Variables
ENV TZ=America/New_York
ARG DEBIAN_FRONTEND=noninteractive

# Install Dependencies
RUN R -e "remotes::install_github('rqthomas/noaaGEFSpoint@b1e61c9c5b2cbba96f7598f4fec02e78d2453f36')" && \
	wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64

# Copy Files to Container
RUN mkdir -p /root/flare/rscripts/
COPY flare-container.sh /root/flare/
RUN wget -O /root/flare/main.sh https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/commons/main.sh
RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh
COPY rscripts/launch_download_downscale.R /root/flare/rscripts/
COPY noaa_download_site_list.csv /root/flare/
