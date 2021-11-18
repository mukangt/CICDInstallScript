###
 # @Author: mukangt
 # @Date: 2021-10-21 15:00:00
 # @LastEditors: mukangt
 # @LastEditTime: 2021-10-21 15:00:00
 # @Description: 
### 
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version