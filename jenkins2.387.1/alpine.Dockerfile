# Build base image
FROM alpine:3.17 
LABEL maintainer="Antonio Salazar <antonio.salazar.devops@gmail.com>"

# Arguments
ARG username
ARG key
ARG port

# Install sudo and set up default user
RUN apk update &&\ 
    apk add sudo &&\
    adduser $username -D -G wheel &&\
    echo "$username:$username" | chpasswd &&\
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

# copy the SSH keys
ADD ./$key.pub /home/$username/.ssh/authorized_keys

RUN chown $(id -u $username):$(id -g $username) -R /home/$username/.ssh && \
    chmod 600 /home/$username/.ssh/authorized_keys &&\
# Install ssh server
    apk add --no-cache openssh && \
# Configure SSHD
    mkdir /var/run/sshd

ADD ./sshd_config /etc/ssh/sshd_config

RUN ssh-keygen -A -v &&\
# Install git
    apk add git &&\
# Install JDK 11
    apk add openjdk11 &&\
# Install ansible
    apk update && apk add ansible &&\
# Install terraform
    apk add terraform --repository=https://dl-cdn.alpinelinux.org/alpine/v3.17/main

USER $username
WORKDIR /home/$username

EXPOSE $port
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]

# docker build . --build-arg key=$key --build-arg username=$username --build-arg port=$port -f alpine.Dockerfile -t alpine/jenkins:3.17