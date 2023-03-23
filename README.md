# CI/CD jenkins
Continuous Integration/Continuous Delivery Project with Jenkins

## Goal 
- Provision a new Jenkins instance in a Virtual Machine running on ubuntu Server 22.04 "jammy".
- The Jenkins instace must be running as a docker container.
- Set up four agent nodes running as docker containers too.
- All of the containers should be running on the same docker network.
- Use one of the node instances as the Ansible controller.
- Keep the data persistent using Docker Volumes.
- Automate the provisioning using different scripts:
  - Terraform: to create a new EC2 instance on AWS.
  - Docker files: to build the Jenkins instance and its Agent images.
  - Docker Compose file: to build and deploy the Jenkins Instance.
  - BASH files: to install and configure the Jenkins instance on the Virtual Machine.
  
# Architecture

This particular a dockerized Controller - Worker model. 

There is a Docker netkork where the jenkins controller and nodes run. Each node is a container set up as a permantent node.

The application data is saved in a docker volume to keep it persistent.

Each node has a different operating system:
- The Alpine node, functions as the Ansible controller.
- Whereas the CentOs, Debian and Ubuntu are the worker nodes.

  ||
  |:--:|
  |![diagram](images/jenkins_architecture_diagram.png)|
  |Architecture Model|

# Installation instructions
1. Clone this repository onto the Virtual Machine running Ubuntu 22.04 "jammy".
2. Ensure the user account you are using has sudo privileges.
3. Change directory `cd jenkins2.387.1`
4. Execute the `install.sh` BASH script.
5. Configure the Jenkins Initial Credentials and plugins.
6. Add the Alpine, CentOS, Debian and Ubuntu nodes accordingly.
7. Run the [ansible_hello.pipeline] to the a simple test.

Further details are described in [01 Installing and Configuring Jenkins](01_installing_jenkins/01_installing_jenkins.md)
