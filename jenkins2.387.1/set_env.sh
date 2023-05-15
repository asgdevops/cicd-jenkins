#!/bin/bash
#
# Metadata
#
metadata() {
  version="v1.1.0";
  dev_date="2023.03.18";
  author="antonio.salazar@ymail.com";
  description="Set up the Environment Variables for the Jenkins instance";
}

#
# Create the env variables file
#
set_env() {

  echo "/*** Set environment variables ***/";

  # project name
  project="jenkins2-387-1";

  # project directory name
  project_dir="jenkins2.387.1";

  # image name
  image='jenkins2.387.1';

  # docker network name   
  network=`echo ${project}_net`;

  # application port
  http_port=8387;

  # application agent port
  agent_port=50000;

  # agent ssh port
  ssh_port=2387;

  # Application working directory
  work_dir=/app/data;

  # Application backup directory
  backup_dir=/app/backup;

  # Jenkins base
  base=`echo ${work_dir}/${project_dir}`;

  # Jenkins certificates directory
  certs_dir=`echo ${base}/jenkins_home/certs/client`;

  # Jenkins data directory
  data_dir=`echo ${base}/jenkins_home`;

  # volume alias data
  volume_certs=`echo ${project}_certs`;

  # volume alias data
  volume_data=`echo ${project}_data`;

  # default username
  username=jenkins;

  # default ssh key 
  ssh_key=`echo ${username}_key`;

  # project_dir java home env variable
  JAVA_HOME=/opt/java/openjdk;

  # project_dir jenkins home env variable
  JENKINS_HOME=/var/jenkins_home;

  # create environment file
  echo "#" > $env_file;
  echo "# Project info" >> $env_file;
  echo "#" >> $env_file;
  echo "context=${base}" >> $env_file;
  echo "project=${project}" >> $env_file ;
  echo "project_dir=${project_dir}" >> $env_file ;
  echo "image=${image}" >> $env_file;
  echo "#" >> $env_file;
  echo "# Network properties" >> $env_file;
  echo "#" >> $env_file;
  echo "network=${network}" >> $env_file;
  echo "agent_port=${agent_port}" >> $env_file;
  echo "http_port=${http_port}" >> $env_file;
  echo "ssh_port=${ssh_port}" >> $env_file;
  echo "#" >> $env_file;
  echo "# Storage properties" >> $env_file;
  echo "#" >> $env_file;
  echo "work_dir=${work_dir}" >> $env_file;
  echo "backup_dir=${backup_dir}" >> $env_file;
  echo "certs_dir=${certs_dir}" >> $env_file;
  echo "data_dir=${data_dir}" >> $env_file;
  echo "volume_certs=${volume_certs}" >> $env_file;
  echo "volume_data=${volume_data}" >> $env_file;
  echo "#" >> $env_file;
  echo "# Login properties" >> $env_file;
  echo "#" >> $env_file;
  echo "username=${username}" >> $env_file;
  echo "ssh_key=${ssh_key}" >> $env_file;
  echo "#" >> $env_file;
  echo "# Environment variables" >> $env_file;
  echo "#" >> $env_file;
  echo "JAVA_HOME=${JAVA_HOME}" >> $env_file;
  echo "JENKINS_HOME=${JENKINS_HOME}" >> $env_file;
  
  ls -l $env_file && cat $env_file ; 
  source $env_file;

  echo "/*** Environment variables set successfuly ***/";
}

#
# Main
#
env_file=".env";
# Set the environment variables
set_env;