### base ###
FROM ubuntu:14.04
MAINTAINER hiroyuki

### add new user ###
RUN useradd -m -d /home/docker -s /bin/bash docker
RUN echo "docker:docker" | chpasswd
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

### use Asia/Tokyo as localtime ###
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN locale-gen ja_JP.UTF-8  
ENV LANG ja_JP.UTF-8  
ENV LANGUAGE ja_JP:en  
ENV LC_ALL ja_JP.UTF-8  

### install apt packages ###
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y autoclean
RUN apt-get -y clean

### tmux , vim , git , curl ###
RUN apt-get -y install tmux git vim curl

### sshd ###
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -i "s/#AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/" /etc/ssh/sshd_config
RUN sed -i 's/\#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
ADD ./id_rsa /home/docker/.ssh/id_rsa
ADD ./id_rsa.pub /home/docker/.ssh/authorized_keys
ADD ./config /home/docker/.ssh/config
RUN chown -R docker. /home/docker/.ssh
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

### Virtual Env ###
RUN apt-get install -y libffi-dev
RUN apt-get install -y python-setuptools
RUN easy_install pip
RUN pip install virtualenv virtualenvwrapper
RUN mkdir /home/docker/.virtualenvs
RUN echo "export WORKON_HOME=/home/docker/.virtualenvs" >> /home/docker/.bash_profile
RUN echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/docker/.bash_profile
RUN chown -R docker. /home/docker
RUN su -l docker -c 'mkvirtualenv --no-site-package --python=/usr/bin/python2.7 env1'

### gcc-4.9 g++-4.9 ###
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update -y
RUN apt-get install -y gcc-4.9 g++-4.9
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9

### Mesos ###
#RUN apt-get install -y openjdk-7-jre
#RUN apt-get install -y openjdk-7-jdk
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y tar wget
RUN apt-get install -y autoconf libtool
RUN apt-get -y install build-essential python-dev python-boto libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev
RUN wget -O /home/docker/mesos-0.27.0.tar.gz http://www.apache.org/dist/mesos/0.27.0/mesos-0.27.0.tar.gz
RUN tar -zxf /home/docker/mesos-0.27.0.tar.gz -C /home/docker/
RUN chown -R docker:docker /home/docker/mesos-0.27.0
WORKDIR /home/docker/mesos-0.27.0
RUN ./configure
RUN make -j 2
RUN chown -R docker:docker /home/docker/mesos-0.27.0

### Marathon ###
RUN apt-get install -y apt-transport-https
RUN echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
RUN apt-get update
RUN apt-get install -y sbt
WORKDIR /home/docker/
RUN git clone https://github.com/mesosphere/marathon.git
WORKDIR /home/docker/marathon
RUN sbt assembly
RUN ./bin/build-distribution
RUN chown -R docker:docker /home/docker/marathon

### Mesos Install ###
WORKDIR /home/docker/mesos-0.27.0
RUN make install

### supervisor ###
ADD ./admin /root/admin
RUN chmod +x /root/admin/main.sh
CMD ["bash","-l","/root/admin/main.sh"]

