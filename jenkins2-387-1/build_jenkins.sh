#!/bin/bash
#
# Metadata
#
metadata() {
  version="v1.1.0";
  dev_date="2023.03.18";
  author="antonio.salazar@ymail.com";
  description="Build Jenkins instance and its agents using Docker Compose Build";
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
# Main
# 

# Set the environment variables
source set_env.sh;

# create the ssh key pair
source set_key.sh;

# Create the directory tree
set_directories; 

# build the docker images
docker compose build ;

if [ $? -eq 0 ]; then
  docker image ls 
fi