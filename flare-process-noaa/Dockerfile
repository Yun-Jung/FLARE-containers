FROM rocker/geospatial:4.0.3

# Set Environment Variables
ENV TZ=America/New_York
ARG DEBIAN_FRONTEND=noninteractive

# Install Dependencies
RUN R -e "remotes::install_github('FLARE-forecast/rNOMADS@78b61c3fd0e47f456fdc20bf5c0dd0234b418710')" && \
  R -e "remotes::install_github('FLARE-forecast/noaaGEFSpoint@fc08f6272da5b7bdeec3b764050e490482d27240')" && \
	wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64

# Copy Files to Container
RUN mkdir -p /root/flare/rscripts/
COPY flare-container.sh /root/flare/
RUN wget https://raw.githubusercontent.com/FLARE-forecast/FLARE-containers/master/commons/commons.sh -O /root/flare/commons.sh
RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh
COPY rscripts/launch_download_downscale.R /root/flare/rscripts/
