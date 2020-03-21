#!/bin/bash

# Take 3 Arguments and Return the First One That Is Not Null
function set_value (){
	[[ ! -z $1 ]] && echo $1 || ([[ ! -z $2 ]] && echo $2 || echo $3)
}

DOCKERHUB_ID="flareforecast"
CONTAINER_NAME="flare-push-test"
CONFIG_FILE="flare-config.yml"
CONTAINER_SCRIPT="flare-container.sh"
DIRECTORY_HOST="/opt/flare"
DIRECTORY_HOST_SHARED="/opt/flare/shared"
DIRECTORY_CONTAINER="/root/flare"
DIRECTORY_CONTAINER_SHARED="/root/flare/shared"

SSHKEY_PRIVATE_DEFAULT=$([[ $EUID -eq 0 ]] && echo "/root/.ssh/id_rsa" || echo "/home/$USER/.ssh/id_rsa")
SSHKEY_PRIVATE_GENERAL=$(yq r $CONFIG_FILE ssh-key.private)
SSHKEY_PRIVATE_CONTAINER=$(yq r $CONFIG_FILE $CONTAINER_NAME.git.ssh-key.private)
SSHKEY_PRIVATE=$(set_value $SSHKEY_PRIVATE_CONTAINER $SSHKEY_PRIVATE_GENERAL $SSHKEY_PRIVATE_DEFAULT)

cp -u $SSHKEY_PRIVATE $DIRECTORY_HOST_SHARED

DOCKER_RUN_COMMAND="docker run -v $DIRECTORY_HOST_SHARED:$DIRECTORY_CONTAINER_SHARED $DOCKERHUB_ID/$CONTAINER_NAME $DIRECTORY_CONTAINER/$CONTAINER_SCRIPT"

# Run Docker
$DOCKER_RUN_COMMAND