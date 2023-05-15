#!/bin/bash
#
# Metadata
#
metadata() {
  version="v1.1.0";
  dev_date="2023.03.19";
  author="antonio.salazar@ymail.com";
  description="Set up the SSH Keys for the Jenkins instance and its Agents";
}

#
# Set up the SSH keys
#
set_key() {
  echo "/*** Create the SSH key ***/";
  
  #
  # Create ssh key in case the Private or Public key does not exist
  #
  if [ ! -f ./${ssh_key}.pub -o ! -f ./${ssh_key} ]; then
    ssh-keygen -f ./${ssh_key} -N '' -q -t ed25519 -C "${username}";
  fi

  #
  # Create sshd_config, in case it does not exist
  #
  if [ ! -f ./sshd_config ]; then
    echo "Port ${ssh_port}" > ./sshd_config ;
    echo "Protocol 2" >> ./sshd_config ;
    echo "" >> ./sshd_config ;
    echo "HostKey /etc/ssh/ssh_host_rsa_key" >> ./sshd_config ;
    echo "HostKey /etc/ssh/ssh_host_dsa_key" >> ./sshd_config ;
    echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> ./sshd_config ;
    echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> ./sshd_config ;
    echo "" >> ./sshd_config ;
    echo "LoginGraceTime 120" >> ./sshd_config ;
    echo "PermitRootLogin no" >> ./sshd_config ;
    echo "StrictModes yes" >> ./sshd_config ;
    echo "" >> ./sshd_config ;
    echo "PasswordAuthentication yes" >> ./sshd_config ;
    echo "ChallengeResponseAuthentication no" >> ./sshd_config ;
    echo "PubKeyAuthentication yes" >> ./sshd_config ;
    echo "UsePAM no" >> ./sshd_config ;
  fi 

  ls -l ./${ssh_key}* ./sshd_config;

  echo "/*** SSH Key created successfully ***/";
}

#
# Main
#

#
# Set the environment variables if not set already
#
if [ ! -f .env ]; then
  source set_env.sh;
elif [ -z "${project}" ]; then
  source set_env.sh;
fi

#
# Create the SSH key
#
set_key;
