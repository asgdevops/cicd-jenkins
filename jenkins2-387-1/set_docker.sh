#!/bin/bash
#
# Metadata
#
metadata() {
  version="v1.1.0";
  dev_date="2023.03.18";
  author="antonio.salazar@ymail.com";
  description="Install Docker CE on Ubuntu 22.04";
}

#
# Install docker
# 
set_docker() {

  #
  # Set up the repository
  #
  # remove old docker versions
  sudo apt remove -y docker docker-engine docker.io containerd runc ;

  # Update the apt package index and install packages to allow apt to use a repository over HTTPS:
  sudo apt update && sudo apt install -y ca-certificates curl gnupg lsb-release ;

  # Add Docker’s official GPG key
  [ ! -d /etc/apt/keyrings ] && sudo mkdir -p /etc/apt/keyrings ;
  [ -f /etc/apt/keyrings/docker.gpg ]  && sudo mv /etc/apt/keyrings/docker.gpg /tmp ;
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg ;

  # Set up the Docker repository
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null ;

  #
  # Install Docker Engine
  #
  sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin ;

  # add docker group to user
  sudo groupadd docker;
  sudo usermod -aG docker ${USER};
  
  # Commands to avoid permission errors
  sudo chown root:docker /var/run/docker.sock
  [ -f /home/${USER}/.docker ] && sudo chown ${USER}:${USER} /home/${USER}/.docker -R ;
  [ -f /home/${USER}/.docker ] && sudo chmod g+rwx "$HOME/.docker" -R ;

}

#
# Main
#
# Install Docker on Ubuntu 22.04
set_docker;
