###
 # @Author: mukangt
 # @Date: 2021-10-23 19:18:20
 # @LastEditors: mukangt
 # @LastEditTime: 2021-10-23 19:34:30
 # @Description: 
### 

# 解压离线安装包
tar -zxvf harbor-offline-installer-v2.3.3.tgz -C /usr/local/

# 配置harbor
cd /usr/local/harbor
cp harbor.yml.tmpl harbor.yml
vi harbor.yml

# 修改以下内容
hostname = HarborHostIP
port:80 
harbor_admin_password = Harbor12345
data_volume: /data

# 关闭https和证书，注释掉这几行

# https related config
#https:
#  # https port for harbor, default is 443
#  port: 443
#  # The path of cert and key files for nginx
#  certificate: /your/certificate/path
#  private_key: /your/private/key/path

# 配置harbor
./prepare

# 安装harbor
./install.sh

# 修改docker配置文件，使docker支持harbor
vi /etc/docker/daemon.json
{"insecure-registries":["HarborHostIP:80"]}

# 重启docker服务
systemctl daemon-reload
systemctl restart docker

# 配置harbor开机自启动
cat >> /usr/lib/systemd/system/harbor.service  <<EOF
[Unit]
Description=Harbor
After=docker.service systemd-networkd.service systemd-resolved.service
Requires=docker.service
Documentation=http://github.com/vmware/harbor
[Service]
Type=simple
Restart=on-failure
RestartSec=5
ExecStart=/usr/local/bin/docker-compose -f /usr/local/harbor/docker-compose.yml up
ExecStop=/usr/local/bin/docker-compose -f /usr/local/harbor/docker-compose.yml down
[Install]
WantedBy=multi-user.target
EOF

systemctl enable harbor
systemctl start harbor