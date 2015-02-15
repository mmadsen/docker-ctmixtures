FROM phusion/baseimage:latest
MAINTAINER Mark E. Madsen "mark@madsenlab.org"

# Add Anaconda Python
ADD src/ /tmp
RUN /tmp/install.sh
ENV PATH /root/anaconda/bin:$PATH 

# Add MongoDB
# Import MongoDB public GPG key AND create a MongoDB list file
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list

# Update apt-get sources AND install MongoDB
RUN apt-get update && apt-get install -y mongodb-org

# Create the MongoDB data directory
RUN mkdir -p /root/db
ADD mongod.conf /etc/mongod.conf

# start mongod using runit from phusion/baseimage
RUN mkdir /etc/service/mongod
ADD mongod /etc/service/mongod/run

# Expose port #27017 from the container to the host
EXPOSE 27017


# Add Git
RUN apt-get install -y git
RUN apt-get install -y wget
RUN apt-get install -y build-essential
RUN apt-get install -y swig

# Add CTMixtures 
WORKDIR /root
RUN git clone https://github.com/mmadsen/ctmixtures.git v2.5

WORKDIR /root/v2.5
RUN /bin/bash install-slatkin-tools.sh
RUN pip install -r requirements.txt
RUN python setup.py install
ADD example-simulation-job.sh example-simulation-job.sh
ADD equifinality-allneutral.json conf/equifinality-allneutral.json


CMD ["/sbin/my_init" , "--","bash", "-l"]
