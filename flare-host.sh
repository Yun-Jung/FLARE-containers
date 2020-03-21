#!/bin/bash

# Take 3 Arguments and Return the First One That Is Not Null
function set_value (){
	[[ ! -z $1 ]] && echo $1 || ([[ ! -z $2 ]] && echo $2 || echo $3)
}

DOCKERHUB_ID="flareforecast"
CONTAINER_NAME="flare-push-test"
CONFIG_FILE="flare-config.yml"
CONTAINER_SCRIPT="flare-container.sh"
SHAREDDIRECTORY="/opt/flare"
APPDIRECTORY="/root/flare"

SSHKEY_PRIVATE_DEFAULT=$([[ $EUID -eq 0 ]] && echo "/root/.ssh/id_rsa" || echo "/home/$USER/.ssh/id_rsa")
SSHKEY_PRIVATE_GENERAL=$(./yq r $CONFIG_FILE ssh-key.private)
SSHKEY_PRIVATE_CONTAINER=$(./yq r $CONFIG_FILE $CONTAINER_NAME.git.ssh-key.private)
SSHKEY_PRIVATE=$(set_value $SSHKEY_PRIVATE_CONTAINER $SSHKEY_PRIVATE_GENERAL $SSHKEY_PRIVATE_DEFAULT)

cp -u $SSHKEY_PRIVATE $SHAREDDIRECTORY

DOCKER_RUN_COMMAND="docker run -v $SHAREDDIRECTORY:$APPDIRECTORY $DOCKERHUB_ID/$CONTAINER_NAME $APPDIRECTORY/$CONTAINER_SCRIPT"

# Run Docker
$DOCKER_RUN_COMMAND