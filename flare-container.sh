#!/bin/bash

# Exit When Any Command Fails
set -e
# Keep Track of the Last Executed Command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# Echo an Error Message Before Exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

TIMESTAMP=$(date +"%D %T")

# Take 3 Arguments and Return the First One That Is Not Null
function set_value (){
	[[ ! -z $1 ]] && echo $1 || ([[ ! -z $2 ]] && echo $2 || echo $3)
}

# Check If the Directory is the Expected Git Repository
function is_right_directory (){
	cd $1
	[ -z `git config --get remote.origin.url | grep "/"$2` ] && echo "Fatal Error: The Git repository '$2' is expected in '`pwd`'." && exit 1
}

# Change Directory to $DIRECTORY_CONTAINER
cd $(dirname $0)

DOCKERHUB_ID="flareforecast"
CONTAINER_NAME="flare-external-driver-interface-noaa"
CONFIG_FILE="flare-config.yml"
NOAA_SCRIPT="/root/flare/grab-weekly-forecast-for-glm-v3.R"
DIRECTORY_CONTAINER_SHARED="/root/flare/shared"

GIT_REMOTE_USER_NAME_DEFAULT=""
GIT_REMOTE_USER_NAME_GENERAL=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE git.remote.user.name)
GIT_REMOTE_USER_NAME_CONTAINER=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE $CONTAINER_NAME.git.remote.user.name)
GIT_REMOTE_USER_NAME=$(set_value $GIT_REMOTE_USER_NAME_CONTAINER $GIT_REMOTE_USER_NAME_GENERAL $GIT_REMOTE_USER_NAME_DEFAULT)

GIT_REMOTE_USER_EMAIL_DEFAULT=""
GIT_REMOTE_USER_EMAIL_GENERAL=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE git.remote.user.email)
GIT_REMOTE_USER_EMAIL_CONTAINER=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE $CONTAINER_NAME.git.remote.user.email)
GIT_REMOTE_USER_EMAIL=$(set_value $GIT_REMOTE_USER_EMAIL_CONTAINER $GIT_REMOTE_USER_EMAIL_GENERAL $GIT_REMOTE_USER_EMAIL_DEFAULT)

GIT_REMOTE_BRANCH_DEFAULT="test1"
GIT_REMOTE_BRANCH_GENERAL=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE git.remote.branch)
GIT_REMOTE_BRANCH_CONTAINER=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE $CONTAINER_NAME.git.remote.branch)
GIT_REMOTE_BRANCH=$(set_value $GIT_REMOTE_BRANCH_CONTAINER $GIT_REMOTE_BRANCH_GENERAL $GIT_REMOTE_BRANCH_DEFAULT)

GIT_REMOTE_SERVER_DEFAULT="github.com"
GIT_REMOTE_SERVER_GENERAL=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE git.remote.server)
GIT_REMOTE_SERVER_CONTAINER=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE $CONTAINER_NAME.git.remote.server)
GIT_REMOTE_SERVER=$(set_value $GIT_REMOTE_SERVER_CONTAINER $GIT_REMOTE_SERVER_GENERAL $GIT_REMOTE_SERVER_DEFAULT)

GIT_REMOTE_REPOSITORY_DEFAULT=""
GIT_REMOTE_REPOSITORY_GENERAL=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE git.remote.repository)
GIT_REMOTE_REPOSITORY_CONTAINER=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE $CONTAINER_NAME.git.remote.repository)
GIT_REMOTE_REPOSITORY=$(set_value $GIT_REMOTE_REPOSITORY_CONTAINER $GIT_REMOTE_REPOSITORY_GENERAL $GIT_REMOTE_REPOSITORY_DEFAULT)

SSHKEY_PRIVATE_DEFAULT=$([[ $EUID -eq 0 ]] && echo "/root/.ssh/id_rsa" || echo "/home/$USER/.ssh/id_rsa")
SSHKEY_PRIVATE_GENERAL=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE ssh-key.private)
SSHKEY_PRIVATE_CONTAINER=$(yq r $DIRECTORY_CONTAINER_SHARED/$CONFIG_FILE $CONTAINER_NAME.git.ssh-key.private)
SSHKEY_PRIVATE=$(set_value $SSHKEY_PRIVATE_CONTAINER $SSHKEY_PRIVATE_GENERAL $SSHKEY_PRIVATE_DEFAULT)

# Extract Directory Name from Remote Repository Name
GIT_DIRECTORY=$(awk -F. '{print $1}' <<< $(awk -F/ '{print $NF}' <<< $GIT_REMOTE_REPOSITORY))

# Extract Private SSH Key File Name from Full Path
SSHKEY_PRIVATE_FILE=$(awk -F/ '{print $NF}' <<< $SSHKEY_PRIVATE)

# Set up SSH
mkdir -p /root/.ssh
cp -u $DIRECTORY_CONTAINER_SHARED/$SSHKEY_PRIVATE_FILE /root/.ssh/id_rsa
ssh-keyscan $GIT_REMOTE_SERVER > /root/.ssh/known_hosts

# Set up Git
git config --global user.name $GIT_REMOTE_USER_NAME
git config --global user.email $GIT_REMOTE_USER_EMAIL

# Clone Git Repository If Doesn't Exist
cd shared
([ -d $GIT_DIRECTORY ] && (is_right_directory $GIT_DIRECTORY "/"$GIT_REMOTE_REPOSITORY)) || git clone git@$GIT_REMOTE_SERVER:$GIT_REMOTE_REPOSITORY 

cd $GIT_DIRECTORY
git checkout $GIT_REMOTE_BRANCH

# Commit Any Uncommited Change
[ ! -z git ls-files --other --exclude-standard --directory ] && git add . && git commit -m "$TIMESTAMP - Previously Uncommited Changes"

git pull --no-edit
Rscript $NOAA_SCRIPT
git add .
git commit -m "$TIMESTAMP - Add NOAA Forecast" #2>&1 | tee -a $LOGFILE
git push #2>&1 | tee -a $LOGFILE

# Remove .ssh Directory for Security Purposes
rm -rf /root/.ssh
