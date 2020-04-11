#!/bin/bash

ADMIN_STACK=./docker-admin-stack.yml
BKPK_STACK=./docker-backpack-stack.yml
INSTALL_ENVIRONMENT=""
DO_TOKEN=""
DOMAIN=""
EMAIL=""

function set_environment() {
  while [ -z "$INSTALL_ENVIRONMENT" ]; do
    read -p "Are you installing Backpack (l)ocally or on (D)igital Ocean? " input

    case $input in
      [Ll]* )
        INSTALL_ENVIRONMENT="local";;
      [Dd]* )
        INSTALL_ENVIRONMENT="DO";;
      * )
        echo "Please answer with L or D";;
    esac
  done
}

function set_domain() {
  while [ -z "$DOMAIN" ]; do
    read -p "Which domain name would you like to associate with this Backpack deployment (something.com)? " input

    # Regex is going to be roughly right...
    domain_pat="^[a-zA-Z-]{1,63}\.[a-zA-Z]{2,}$"
    if [[ $input =~ $domain_pat ]]; then
      DOMAIN="$input"
    else
      echo "Please enter a valid domain name."
    fi
  done
}

function set_email() {
  while [ -z "$EMAIL" ]; do
    read -p "Which email address is associated with this domain's DNS records? " input

    # Regex is going to be roughly right...
    email_pat="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    if [[ $input =~ $email_pat ]]; then
      EMAIL="$input"
    else
      echo "Please enter a valid email address."
    fi
  done
}

function set_DO_token() {
  read -p "What's your DO API token? " token
  DO_TOKEN="$token"
}


function install_docker() {
  # checking if docker is installed
  if [ -x "$(command -v docker)" ]; then
    DOCKER_INSTALLED=true
  else
    DOCKER_INSTALLED=false
  fi

  # install it if it's not.
  if [ "$DOCKER_INSTALLED" = false ]; then
    echo "Installing Docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
  fi
}

function install_docker_machine() {
  # checking if docker is installed
  if [ -x "$(command -v docker-machine)" ]; then
    DOCKER_MACHINE_INSTALLED=true
  else
    DOCKER_MACHINE_INSTALLED=false
  fi

  # install it if it's not.
  if [ "$DOCKER_MACHINE_INSTALLED" = false ]; then
    echo "Installing docker-machine"
    curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine
    chmod +x /tmp/docker-machine
    sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
  fi
}

function start_swarm() {
  # check if swarm is running
  NODE_STATE="$(docker info --format '{{.Swarm.LocalNodeState}}')"

  if [ $NODE_STATE = "inactive" ] || [ $NODE_STATE = "pending" ]; then
    ACTIVATE_SWARM=true
  else
    ACTIVATE_SWARM=false
  fi

  if $ACTIVATE_SWARM; then
    PUBLIC_IP_ADDRESS="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    echo $PUBLIC_IP_ADDRESS
  fi
}

set_environment

if [ $INSTALL_ENVIRONMENT = "local" ]; then
  install_docker
else
  install_docker_machine
  set_DO_token
  set_domain
  set_email
fi

start_swarm

echo $INSTALL_ENVIRONMENT
