# :book: 1. Installing and configuring Jenkins

## Goal 
- Provision a new Jenkins instance in a Virtual Machine running on Ubuntu Server 22.04 "jammy"
- The Jenkins instance must be running as a docker container.
- Set up four agent nodes running as docker containers too.
- All of the containers should be running on the same docker network.
- Use one of the node instances as the Ansible controller.

## Requiremens
According to [Jenkins on Docker](https://www.jenkins.io/doc/book/installing/docker/) documentation, the requirements demand at least 256MB of RAM and 10 GB of disk.

The resources used in this lab, presented in this document, are configured in the following way:

**Virtual Hardware**
- 8GB of RAM.
- 4 CPUs.
- 10GB of the bootable disk.
- 30GB of the data disk.
- Intel Nic Network device.

**Software**
- Ubuntu 22.04 server ("jammy") operating system.
- git 2.25.1 
- Python 3.8.10 
- Jenkins 2.387.1 Docker image.
- Docker 20.10.23

The software could install on a Baremetal, laptop, PC, or any Virtual Machine running on Oracle VirtualBox, Vagrant, VMWare, or any Cloud computing provider such as AWS, Azure, GCP, or Oracle OCI.
  
# Architecture

The architecture is a typical container Controller-Worker model. 

There is a Docker network where the Jenkins controller and nodes run. Each node is a container set up as a permanent node.

The application data is saved in a docker volume to keep it persistent.

Each node has a different operating system:
- The Alpine node functions as the Ansible controller.
- Whereas the CentOs, Debian, and Ubuntu are the worker nodes.

  ||
  |:--:|
  |![diagram](images/jenkins_architecture_diagram.png)|
  |Architecture Model|

# Installation 

The Jenkins installation runs by a series of BASH scripts combined with Docker and docker-compose files.

The aim is to implement the Continuous Integration/Continuous Delivery process from the beginning until the end of the project.

## Scripts usage

### Main Scripts

|No.|Script name|Purpose or function|Links to|
|--:|--|--|--|
|1|[install_jenkins.sh](jenkins2-387-1/install_jenkins.sh)|Jenkins installer for Ubuntu 22.04 systems. <br/> 1. Creates the `.env` environments variable file. <br/> 2. Installs Docker Engine. <br/> 3. Configures the persistent volumes directories. <br/> 4. Creates the SSH key pair (ed25519) to keep the jenkins controller and nodes working together. <br/> 5. Launches the `docker-compose.yml` file to build and run the Jenkins containers.|--> docker-compose.yml file|
|2|[docker-compose.yml](jenkins2-387-1/docker-compose.yml)|1. Builds the images of the Jenkins controller and agent nodes. <br/> 2. Creates the containers from the docker images. <br/> 3. Creates the Docker network. <br/> 4. Binds the docker volumes for persitent data.|--> jenkins.Dockerfile <br/> --> centos.Dockerfile <br/> --> debian.Dockerfile <br/> --> ubuntu.Dockerfile|
|3|[alpine.Dockerfile](jenkins2-387-1/alpine.Dockerfile)|Builds the alpine:3.17 controller node. <br/> 1. Sets up the jenkins user with root privileges. <br/> 2. Installs and configures SSHD. <br/> 3. Installs git, openJDK 11, Ansible and Terraform. ||
|4|[centos.Dockerfile](jenkins2-387-1/centos.Dockerfile)|Builds the centos:7 agent node. <br/> 1. Sets up the jenkins user with root privileges. <br/> 2. Installs and configures SSHD. <br/> 3. Installs git and openJDK 11.||
|5|[debian.Dockerfile](jenkins2-387-1/debian.Dockerfile)|Builds the debian:11 agent node. <br/> 1. Sets up the jenkins user with root privileges. <br/> 2. Installs and configures SSHD. <br/> 3. Installs git and openJDK 11.||
|6|[ubuntu.Dockerfile](jenkins2-387-1/ubuntu.Dockerfile)|Builds the ubuntu:22.04 agent node. <br/> 1. Sets up the jenkins user with root privileges. <br/> 2. Installs and configures SSHD. <br/> 3. Installs git and openJDK 11.||

### Auxiliary Scripts

Script name|Purpose or function
--|--|
|[set_docker.sh](jenkins2-387-1/set_docker.sh)|Install Docker on Ubuntu 22.04 server|
|[set_env.sh](jenkins2-387-1/set_env.sh)|Configure the Jenkins Instance Environment Variables|
|[set_key.sh](jenkins2-387-1/set_key.sh)|Create the SSH Key used to connect the Jenkins instance with the agent nodes|

### Maintenance Scripts

Script name|Purpose or function
|--|--|
|[start_jenkins.sh](jenkins2-387-1/start_jenkins.sh)|Start the Jenkins instance using Docker Compose|
|[stop_jenkins.sh](jenkins2-387-1/stop_jenkins.sh)|Stop the Jenkins Instance using Docker Compose|
|[backup_jenkins.sh](jenkins2-387-1/backup_jenkins.sh)|Backup Jenkins data|
|[restore_jenkins.sh](jenkins2-387-1/restore_jenkins.sh)|Restore Jenkins data|


# Steps

1. Ensure the Ubuntu Virtual Machine is running and start a new SSH session.

    ```bash
    ssh -i $KEY $USER@$HOST -p $SSH_PORT
    ```

    |![jenkins](images/jenkins_setup_01.png)|
    |:--:|
    |Figure 1 - SSH log into VM |

    _Notice the Virtual Machine could be set up in a local computer, a baremetal or a cloud computing instance._

2. Clone the [asgdevops/cd-project-jenkins](https://github.com/asgdevops/cd-project-jenkins.git) GitHub repository

    ```bash
    git clone https://github.com/asgdevops/cd-project-jenkins.git

    cd cd-project-jenkins
    ```

    |![jenkins](images/jenkins_setup_02.png)|
    |:--:|
    |Figure 2 - clone cd-project-jenkins repository |

3. Ensure the user account you are using has sudo privileges.

    ```bash
    sudo cat /etc/os-release
    ```

    |![jenkins](images/jenkins_setup_03.png)|
    |:--:|
    |Figure 3 - SSH log into VM |

4. Locate on the jenkins\<version\> directory.

    ```bash
    cd jenkins2-387-1
    ```

5. Run the `install_jenkins.sh` shell script.

    ```bash
    ./install_jenkins.sh
    ```

    _Depending on the VM spped, it shall take between 5 to 20 minutes to complete._

      |![jenkins](images/jenkins_setup_04a.png)|
    |:--:|
    |Figure 4a - install_jenkins.sh part I |

    When the installation process gets completed, you should see five containers running:

    |No.|Container|Descriptions|
    |--:|--|--|
    |1|jenkins|Jenkins master controller|
    |2|alpine-controller|Alpine agent working as the Ansible master controller|
    |3|centos-agent|CentOS 7 agent node|
    |4|debian-agent|Debian 11 ("bullseye") agent node|
    |5|ubuntu-agent|Ubuntu 22.04 ("jammy") agent node|

    There should be also:

    |No.|Resource name|Description|Cmd|
    |--:|--|--|--|
    |1|jenkins_net|Docker bridge network resource|`sudo docker network ls`|
    |2|jenkins_data|Docker persistent volume bind to `/app/data/jenkins2-387-1/jenkins_home` directory|`sudo docker network ls`|

    |![jenkins](images/jenkins_setup_04b.png)|
    |:--:|
    |Figure 4b - install_jenkins.sh part II |


<br/>

# Configuring Jenkins Part I: Admin Credentials and First plugins

5. Get the **initial Admin Password**from the logs.

- Option 1: Opening the `/var/jenkins_home/secrets/initialAdminPassword` file.

  ```bash
  sudo docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
  ```

  |![jenkins](images/jenkins_setup_05.png)|
  |:--:|
  |Figure 5 - Jenkins initial Admin Password from file |

- Option 2: Gather it from the container log.

  ```bash
  docker logs jenkins
  ```

  |![jenkins](images/jenkins_setup_06.png)|
  |:--:|
  |Figure 6 - Jenkins initial Admin Password from log|

6. Login to Jenkins application in the web browser.
   - Open a new Web Browser and go to `http://localhost:8080`
   - Type the admin password taken from the jenkins Docker container

       |![jenkins](images/jenkins_setup_07.png)|
       |:--:|
       |Figure 7 - Unlock Jenkins|

   - Click on the **Install suggested plugins** button

       |![jenkins](images/jenkins_setup_08.png)|
       |:--:|
       |Figure 7a - Customize Jenkins|

   - Monitor the progress of the plug ins installation

       |![jenkins](images/jenkins_setup_09.png)|
       |:--:|
       |Figure 7b - Getting Started|

   - Input the **Admin User** credentials

       |![jenkins](images/jenkins_setup_10.png)|
       |:--:|
       |Figure 7c - Create First Admin User|

   - Set up the Jenkins Application URL and port number

       |![jenkins](images/jenkins_setup_11.png)|
       |:--:|
       |Figure 7d - Instance Configuration|

   - After getting the confirmation page, click on **Start using Jenkins**

       |![jenkins](images/jenkins_setup_12.png)|
       |:--:|
       |Figure 7e - Jenkins is ready!|

   - Now the Jenkins Dashboard screen is open

       |![jenkins](images/jenkins_setup_13.png)|
       |:--:|
       |Figure 7f - Jenkins Dashboard|


# Configuring Jenkins Part II: Set up the Agent Nodes
8. Add the **SSH Agent** and the **CloudBees** plugins.

    |![jenkins](images/jenkins_setup_aws_creds_01.png)|
    |:--:|
    |Figure 8a - Jenkins AWS CloudBeess plugin|

    |![jenkins](images/jenkins_setup_aws_creds_02.png)|
    |:--:|
    |Figure 8b - Jenkins AWS CloudBeess plugin|

9. Add the **AWS Account**credentials.

    |![jenkins](images/jenkins_setup_aws_creds_03.png)|
    |:--:|
    |Figure 9a - Jenkins AWS credentials|

    |![jenkins](images/jenkins_setup_aws_creds_04.png)|
    |:--:|
    |Figure 9b - Jenkins AWS Credentials|

    |![jenkins](images/jenkins_setup_aws_creds_05.png)|
    |:--:|
    |Figure 9c - Jenkins AWS Credentials|


10. Add the Alpine, CentOS, Debian and Ubuntu nodes accordingly.

    - Go to **Manage Jenkins** 

      |![jenkins](images/jenkins_node_setup_01.png)|
      |:--:|
      |Figure 10a - Manage Jenkins|

    - **Manage nodes and clouds**

      |![jenkins](images/jenkins_node_setup_02.png)|
      |:--:|
      |Figure 10b - Manage Nodes and Clouds|

    - Click on **+ New node**

      |![jenkins](images/jenkins_node_setup_03.png)|
      |:--:|
      |Figure 10c - New Node|

    - Enter the **Node Name** and click on **Create**

      |![jenkins](images/jenkins_node_setup_04.png)|
      |:--:|
      |Figure 10d - Node Name|

      _Jenkins allow to copy from another node to speed up filling up the fields._

    - Select Type **Permanent Agent**
    - Click on **Create**
    - Depending on the node, type the corresponding node name [Alpine || Centos || Debian || Ubuntu]
    - Number of Executors: **3**
    - Remote root directory: `/home/jenkins`. _The reason of this, is because when building the docker images, jenkins user was created within its SSH keys._
    - In lables enter the following:
      - For Alpine controler: **`alpine_controller`**.
      - For the rest of the agents: **`[centos||debian||ubuntu]_worker`**.
    - Usage: **Only build jobs with label expressions matching this node**.
    - Launch method: Launch agents via SSH.

      |![jenkins](images/jenkins_node_setup_05.png)|
      |:--:|
      |Figure 10e - Permanent Agent|

    - On Credentials, it this is the first time you input the credential :
      - click on **+ Add**
      - On the Jenkins Credentials Provider: Jenkins Screen.
        - Domain: **Global credentials (unrestricted)**
        - Kind: **SSH Username with pivate key**
        - Scope: **Global (Jenkins, nodes, items, all child items, etc.)**
        - Id: **agent_ssh_jenkins**
        - Description: **Jenkins Agent SSH Private Key**
        - Username: **jenkins**
        - Private Key: **selected**
        - Go to your terminal and open the **`jenkins_key`** file and copy its contents.
        - Go back to the Jenkins Credential screen, and click on the **Add** button. 
        - Paste the private SSH key.
        - **Save**.
        - This takes you back to the previous screen, so choose the ssh credentials just entered.
        - Host Key verification strategy: **Non verifying Verification Strategy**.
        - Availability: **Keep this agent online as much as possible**. 

        |![jenkins](images/jenkins_node_setup_06.png)|
        |:--:|
        |Figure 10f - Permanent Agent|

      - At the end you should see the screen with all the agents summary.

        |![jenkins](images/jenkins_node_setup_07.png)|
        |:--:|
        |Figure 10g - Permanent Agent|



11. Run the [ansible_hello.pipeline](https://github.com/asgdevops/cd-project-ansible/blob/main/ansible_hello.jenkinsfile) to the a simple test.

- Go to Jenkins **Dashboard**
- Click on **+ New Item**
- Type `ansible_version.pipeline` 
- Select **Piepline** and click **OK**
- Fill in the follwing fields
  - Check **Discard Old builds** to save disk space.
  - Choose the number of days or runs you would like to keep. 

    |![jenkins](images/jenkins_pipeline_setup_01.png)|
    |:--:|
    |Figure 11a - Permanent Agent|

  - In the Pipeline section select the following:

    - Definition: **Pipeline Script from SCM**
      - SCM: **Git**
      - Repository URL: (your repository) in this example [asgdevops/ansible](https://github.com/asgdevops/cd-project-ansible)
      - Branch Specifier (blank for 'any'): ***/main**
      - Script Path: (your pipeline script name) in this example [ansible_hello.jenkinsfile](https://github.com/asgdevops/cd-project-ansible/blob/main/ansible_hello.jenkinsfile)
      - **Save**.


      |![jenkins](images/jenkins_pipeline_setup_02.png)|
      |:--:|
      |Figure 11b - Pipeline|

  - Build and monitor the job progress.

    |![jenkins](images/jenkins_pipeline_setup_03.png)|
    |:--:|
    |Figure 11c - Permanent Agent|

# :scroll: Scripts
|Script name| Description|
|--|--|
|[.env](jenkins2-387-1/.env)|Environment variables generated by the `install_jenkins.sh` script.|
|[install_jenkins.sh](jenkins2-387-1/install_jenkins.sh)|Jenkins on Docker installer. Creates the directory structure used by the Docker Volumes.Installs Docker on the system and calls the `docker-compose.yml` script. It also creates the jenkins SSH keys to connect between the controller and the agents.|
|[docker-compose.yml](jenkins2-387-1/docker-compose.yml)|Docker orchestrator builder. Builds the docker images of the jenkins controller and its nodes. Creates the Docker network, and bins the docker volumes for persitent data.|
|[alpine.Dockerfile](jenkins2-387-1/alpine.Dockerfile)|Builds the Alpine 3.17 agent node. It functions as the Ansible Master controller for the remianing nodes. It also has the Terraform packages to use it as a provisioning instance.|
|[centos.Dockerfile](jenkins2-387-1/alpine.Dockerfile)|Builds the CentOS 7 agent node.|
|[debian.Dockerfile](jenkins2-387-1/alpine.Dockerfile)|Builds the Debian 11 agent node.|
|[ubuntu.Dockerfile](jenkins2-387-1/alpine.Dockerfile)|Builds the ubuntu 22.04 agent node.|
|[jenkins.Dockerfile](jenkins2-387-1/alpine.Dockerfile)|Builds the Jenkins controller node version 2.387 with blueocean plugins.|
|[sshd_config](jenkins2-387-1/sshd_config)|Configuration parameters file to set up SSHD on each of the aget nodes.|

<br/>

# :page_facing_up: Log file examples

- [ansible_hello.log](logs/ansible_hello.log)


# :books: References

- [Installing Jenkins - Docker](https://www.jenkins.io/doc/book/installing/docker/)

## Repositories used in this process

- :link: [asgdevops/cd-project-ansible](https://github.com/asgdevops/cd-project-ansible)
- :link: [asgdevops/pipelines](https://github.com/asgdevops/pipelines)
