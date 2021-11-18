###
 # @Author: mukangt
 # @Date: 2021-10-21 15:27:12
 # @LastEditors: mukangt
 # @LastEditTime: 2021-10-21 15:30:28
 # @Description: 
### 
# 安装相关包
yum install make gcc perl pcre-devel zlib-devel
# 安装openssl
tar xvf openssl-1.1.1l.tar.gz
cd openssl-1.1.1l/
./config --prefix=/usr/local/openssl
make & make install