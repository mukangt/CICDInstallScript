###
 # @Author: mukangt
 # @Date: 2021-11-02 16:19:19
 # @LastEditors: mukangt
 # @LastEditTime: 2021-11-03 18:05:09
 # @Description: 
### 
# 设置主机名
hostnamectl set-hostname k8s-master01

# 修改host
xxx.xxx.xxx.xxx k8s-master01
xxx.xxx.xxx.xxx k8s-worker01

# 同步时间
timedatectl set-timezone Asia/Shanghai

# 禁用交换分区
swapoff -a && sed -ri 's/.*swap.*/#&/' /etc/fstab

# 调整内核参数
cat > /etc/sysctl.d/kubernetes.conf << EOF
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF

sysctl -p /etc/sysctl.d/kubernetes.conf

# 安装相关依赖包
yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wget && \
yum install -y vim net-tools git iproute lrzsz bash-completion tree bridge-utils unzip && \
yum install -y bind-utils gcc

# 安装docker
bash docker-install.sh

# 配置docker镜像加速及修改cgroups驱动程序
cat > /etc/docker/daemon.json <<EOF
{
"registry-mirrors": ["https://vad6vlr7.mirror.aliyuncs.com"],
"exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl daemon-reload
systemctl restart docker

# 安装 kubeadm、kubelet、kubectl
# 添加 kubernetes yum源（阿里）
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 关闭防火墙
setenforce 0

# 查看仓库支持的软件版本
yum list kubelet --showduplicates | sort -r
# 安装
yum install -y kubelet-1.22.3 kubeadm-1.22.3 kubectl-1.22.3
# 设置kubelet开机启动
systemctl enable kubelet && systemctl start kubelet

# master初始化
# 查看组件版本（修改相应的docker镜像版本）
kubeadm config images list
# docker预先拉取相关版本
docker pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.22.3 && \
docker tag registry.aliyuncs.com/google_containers/kube-apiserver:v1.22.3 k8s.gcr.io/kube-apiserver:v1.22.3 && \

docker pull registry.aliyuncs.com/google_containers/kube-controller-manager:v1.22.3 && \
docker tag registry.aliyuncs.com/google_containers/kube-controller-manager:v1.22.3 k8s.gcr.io/kube-controller-manager:v1.22.3 && \

docker pull registry.aliyuncs.com/google_containers/kube-scheduler:v1.22.3 && \
docker tag registry.aliyuncs.com/google_containers/kube-scheduler:v1.22.3 k8s.gcr.io/kube-scheduler:v1.22.3 && \

docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.22.3 && \
docker tag registry.aliyuncs.com/google_containers/kube-proxy:v1.22.3 k8s.gcr.io/kube-proxy:v1.22.3&& \

docker pull registry.aliyuncs.com/google_containers/pause:3.5 && \
docker tag registry.aliyuncs.com/google_containers/pause:3.5 k8s.gcr.io/pause:3.5 && \

docker pull registry.aliyuncs.com/google_containers/etcd:3.5.0-0 && \
docker tag registry.aliyuncs.com/google_containers/etcd:3.5.0-0 k8s.gcr.io/etcd:3.5.0-0 && \

docker pull coredns/coredns:1.8.4 && \
docker tag coredns/coredns:1.8.4 k8s.gcr.io/coredns/coredns:v1.8.4

# master 节点初始化
kubeadm init --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12

#### 在主节点 master
iptables -t nat -A OUTPUT -d <主节点公网IP> -j DNAT --to-destination <主节点私有IP>

#### 在 node 节点上
iptables -t nat -A OUTPUT -d <主节点私有IP> -j DNAT --to-destination <主节点公网IP>

# 安装网络插件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# worker加入集群
# 查看join命令
kubeadm token create --print-join-command