#!/bin/bash

# Import Configurations
source flare-install.conf

fails=0

# Check If the URLs Exist
curl --output /dev/null --silent --head --fail $YQ_EXEC || let fails++
curl --output /dev/null --silent --head --fail $FLARE_CONFIG || let fails++
curl --output /dev/null --silent --head --fail $FLARE_HOST || let fails++

exit $fails