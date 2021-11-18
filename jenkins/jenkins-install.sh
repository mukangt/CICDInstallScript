###
 # @Author: mukangt
 # @Date: 2021-10-21 14:07:12
 # @LastEditors: mukangt
 # @LastEditTime: 2021-10-24 17:55:09
 # @Description: 
### 
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum upgrade
yum -y install epel-release java-1.8.0-openjdk-devel
# yum -y install jenkins
rpm -ivh jenkins-2.303.2-1.1.noarch.rpm
systemctl daemon-reload

# 解决宿主机无法访问虚机的端口问题
# 查看端口是否开放
firewall-cmd --query-port=8080/tcp
# 开放相应端口
firewall-cmd --add-port=8080/tcp
# 列出开放的端口号
firewall-cmd --zone=public --list-ports


# 安装完以后重要的目录说明：
# /usr/lib/jenkins/jenkins.war    WAR包 
# /etc/sysconfig/jenkins       配置文件
# /var/lib/jenkins/       默认的JENKINS_HOME目录
# /var/log/jenkins/jenkins.log    Jenkins日志文件
