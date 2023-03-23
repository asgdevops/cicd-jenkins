# Build base image
FROM ubuntu:22.04

LABEL maintainer="Antonio Salazar <antonio.salazar.devops@gmail.com>"

# Disable interactive mode
ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Arguments username and SSH key
ARG key
ARG username
ARG port

# Install sudo and set up default user
RUN apt update -y && \ 
    apt install -y sudo && \
    useradd -rm -d /home/$username -s /bin/bash -g root -G sudo -u 1000 $username && \
    echo $username:$username | chpasswd && \
    mkdir -p /home/$username/.ssh && \
    chmod 700 /home/$username/.ssh && \
    echo "$username  ALL=(ALL:ALL)  NOPASSWD: ALL" >> /etc/sudoers 

# Set up the SSH key
ADD ./$key.pub /home/$username/.ssh/authorized_keys

# Grant privileges to default user on ~/.ssh directory
RUN chown $(id -u $username):$(id -g $username) -R /home/$username/.ssh && \
    chmod 600 /home/$username/.ssh/authorized_keys && \
# Set up SSHD
    apt update -y && apt install -y openssh-server && \
    mkdir /var/run/sshd

ADD ./sshd_config /etc/ssh/sshd_config

RUN ssh-keygen -A -v && \
# install packages: git, and java
    apt install -y git && \
    apt install -y openjdk-11-jdk && \
# Cleanup old packages
    apt -y autoremove 

# Switch to default user
USER $username
WORKDIR /home/$username

EXPOSE $port
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]

# docker build . --build-arg key=$key --build-arg username=$username --build-arg port=$port -f ubuntu.Dockerfile -t ubuntu/jenkins:22.04
