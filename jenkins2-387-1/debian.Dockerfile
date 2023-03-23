# Build base image
FROM debian:11-slim 

LABEL maintainer="Antonio Salazar <antonio.salazar.devops@gmail.com>"

# Disable interactive mode
ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Arguments
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
    echo "$username    ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers 

ADD ./$key.pub /home/$username/.ssh/authorized_keys

RUN chown $(id -u $username):$(id -g $username) -R /home/$username/.ssh && \
    chmod 600 /home/$username/.ssh/authorized_keys

# Install and setup SSHD
RUN apt update -y && apt install -y openssh-server && \
    mkdir /var/run/sshd
ADD ./sshd_config /etc/ssh/sshd_config
RUN ssh-keygen -A -v && \
# install packages: git, java and python
    apt install -y git && \
    apt install -y openjdk-11-jdk && \
    apt install -y python3 python3-pip && \
# Cleanup old packages
    apt -y autoremove 

# Switch to default user
USER $username
WORKDIR /home/$username

EXPOSE $port
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]

# docker build . --build-arg key=$key --build-arg username=$username --build-arg port=$port -f debian.Dockerfile -t debian/jenkins:11