# Backup and Restore LAb
# Backup
jenkins_backup -s /app/data/jenkins2.387.1/jenkins_home -d /app/backup/jenkins2.387.1

# Restore 
## List
jenkins_restore -s /app/backup/jenkins2.387.1/ -d /app/data/jenkins2.387.1/jenkins_home -a list

## Restore
jenkins_restore -s /app/backup/jenkins2.387.1/2023-05-15T09.10.54 -d /app/data/jenkins2.387.1/jenkins_home -a restore


# Destroy data
cd /app/data
sudo rm -rf /app/data/jenkins2.387.1
docker volume rm jenkins2-387-1_certs jenkins2-387-1_data jenkins_certs_client jenkins_data


# Destroy code
cd ~/portfolio
rm -rf cicd-jenkins


# Restore code
git clone git@github.com:asgdevops/cicd-jenkins.git
cd cicd-jenkins/
cd jenkins2-387-1/
./install_jenkins.sh 
docker logs jenkins2.387.1

## Do installation
## Do restore
jenkins_restore -s /app/backup/jenkins2.387.1/2023-05-15T09.10.54 -d /app/data/jenkins2.387.1/jenkins_home -a restore

# restart jenkins
jenkins_stop
jenkins_start




