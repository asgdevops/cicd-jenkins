#!/bin/bash
#
# Metadata
#
metadata() {
  version="v1.1.0";
  dev_date="2023.03.18";
  author="antonio.salazar@ymail.com";
  description="Install Jenkins on Ubuntu 22.04";
}

#
# Create the application directories
#
set_directories() {

  echo "Create the ${container} directory structure";

  [ ! -d ${work_dir} ] && sudo mkdir -p ${work_dir} ;

  sudo chgrp docker ${work_dir};
  sudo chmod g+rwx ${work_dir};

  # create jenkins directory structure
  [ ! -d ${certs_dir} ] && sudo mkdir -p ${certs_dir};
  [ ! -d ${data_dir} ] && sudo mkdir -p ${data_dir};
  
  sudo chown -R $USER:docker ${base};
  sudo chmod -R g+rwx ${base};
  sudo chown $USER:docker .env;

  echo "Directory structure completed successfully.";
  tree ${base};
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
  echo "Jenkins Initial Admin Password: `sudo docker exec -it ${project} cat /var/jenkins_home/secrets/initialAdminPassword`"
}

#
# Main
#

# Set the environment variables
source set_env.sh;

# create the ssh key pair
source set_key.sh;

# Install docker
source set_docker.sh;

# Create the directory tree
set_directories; 

# Set up the containerss
set_container;   