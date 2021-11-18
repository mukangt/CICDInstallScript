###
 # @Author: mukangt
 # @Date: 2021-10-21 15:21:44
 # @LastEditors: mukangt
 # @LastEditTime: 2021-10-23 21:39:02
 # @Description: 
### 

# 安装依赖包
yum install -y curl policycoreutils-python openssh-server

# 配置ssh服务
systemctl start sshd
systemctl enable sshd

# 安装postfix
yum install postfix
systemctl enable postfix
vim /etc/postfix/main.cf
# 修改如下
inet_interfaces = all

systemctl start postfix

# 添加gitlab软件包仓库
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash

# 安装gitlab
EXTERNAL_URL="GitLab服务器的公网IP地址" yum install -y gitlab-ce

# 不需要执行，如有必要可以执行
# 后期如要修改域名
vi /etc/gitlab/gitlab.rb

external_url 'GitlabHostIP'

# 执行配置重启
gitlab-ctl reconfigure
gitlab-ctl start