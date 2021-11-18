# remove old docker
###
 # @Author: mukangt
 # @Date: 2021-10-21 13:56:23
 # @LastEditors: mukangt
 # @LastEditTime: 2021-11-18 10:42:49
 # @Description: 
### 
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# install docker utils
yum install -y yum-utils device-mapper-persistent-data lvm2

# set docker yum repo
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# install docker ce
yum install -y docker-ce docker-ce-cli containerd.io

# start docker
systemctl enable docker
systemctl start docker