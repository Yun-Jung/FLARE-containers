FROM python:3

# Set Environment Variables
ENV TZ=America/New_York
ARG DEBIAN_FRONTEND=noninteractive

# Install Dependencies
RUN wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64
RUN pip3 install pycurl certifi

# Copy Files to Container
RUN mkdir -p /root/flare/pyscripts/
COPY flare-container.sh /root/flare/
RUN wget -O /root/flare/commons.sh https://raw.githubusercontent.com/Yun-Jung/FLARE-containers/master/commons/commons.sh
RUN chmod +x /usr/bin/yq /root/flare/flare-container.sh
COPY /pyscripts/QueuedDownloader.py /root/flare/pyscripts
