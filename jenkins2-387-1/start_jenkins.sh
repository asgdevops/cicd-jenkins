#!/bin/bash
#
# Metadata
#
metadata() {
  version="v1.1.0";
  dev_date="2023.03.18";
  author="antonio.salazar@ymail.com";
  description="Start Jenkins instance and its agents using Docker Compose";
}

#
# Create the Jenkins container
#
set_container() {

  # Create the jenkins contaienr
  echo "Create the Jenkins containers"; 
  sudo docker compose -p ${project} -f docker-compose.yml up -d  
  
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

  # Show jenkins initial admin password
  sleep 3;
  sudo docker logs ${project} 

  # Get the Jenkins Initial Admin Password
  echo "Jenkins Initial Admin Password: `sudo docker logs ${project}`"
}


#
# Main
#

# Set the environment variables
source set_env.sh;

# Set up the containerss
set_container;   