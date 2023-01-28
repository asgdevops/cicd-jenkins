# Build base image
FROM centos:7 AS centos-base

LABEL maintainer="Antonio Salazar <antonio.salazar.devops@gmail.com>"

USER root

# Arguments
ARG username
ARG key

# Install sudo 
RUN yum install -y sudo 

# Set up user
RUN useradd -rm -d /home/$username -s /bin/bash -g root -G wheel -u 1000 $username && \
    echo $username:$username | chpasswd && \
    mkdir -p /home/$username/.ssh && \
    chmod 700 /home/$username/.ssh && \
    echo "$username  ALL=(ALL:ALL)  NOPASSWD: ALL" >> /etc/sudoers 

# Copy ssh publick key
COPY $key.pub /home/$username/.ssh/authorized_keys

# Grant default user access to .ssh directory
RUN chown $(id -u $username):$(id -g $username) -R /home/$username/.ssh && \
    chmod 600 /home/$username/.ssh/authorized_keys

# Build from base
FROM centos-base AS centos-ssh

# Install SSHD
RUN yum install -y openssh-server 

# Configure SSHD
RUN mkdir /var/run/sshd
ADD ./sshd_config /etc/ssh/sshd_config
RUN ssh-keygen -A -v

# install packages: git, java, and maven
RUN yum install -y git.x86_64 && \
    yum install -y java-11-openjdk-devel 

# Update the java version to jdk11
RUN mv /etc/alternatives/java /etc/alternatives/java.old && \
    ln -s /usr/lib/jvm/java-11-openjdk-11.0.17.0.8-2.el7_9.x86_64/bin/java /etc/alternatives/java

USER $username
WORKDIR /home/$username

EXPOSE 22
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]

# docker build . --build-arg key=jenkins_key --build-arg username=jenkins -f centos.Dockerfile -t centos/ssh:7