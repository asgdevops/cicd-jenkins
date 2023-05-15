#!/bin/bash
#
# Metadata
#
metadata() {
  version="v1.1.0";
  dev_date="2023.03.18";
  author="antonio.salazar@ymail.com";
  description="Stop Jenkins instance and its agents using Docker Compose";
}

#
# Create the Jenkins container
#
unset_container() {

  # Create the jenkins contaienr
  echo "Create the Jenkins containers"; 
  sudo docker compose down  
  
  # list volumes
  echo "Docker Volumes";
  sudo docker volume ls 
  echo;

  # list network
  echo "Docker Networks";
  sudo docker network ls
  echo;

  # show docker containers
  echo "Docker Containers";
  sudo docker ps ;
  echo;
}


#
# Main
#

# Set the environment variables
source set_env.sh;

# Stop the containerss
unset_container;