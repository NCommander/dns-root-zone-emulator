# Grab the latest version of Ubuntu as it represents a common server env
FROM ubuntu:latest
MAINTAINER michael@casadevall.pro

# First install updates and then install BIND
RUN apt-get -y update
RUN apt-get -y dist-upgrade
RUN apt-get -y install ubuntu-standard
RUN apt-get -y install openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

CMD ["/usr/sbin/sshd", "-D"]
