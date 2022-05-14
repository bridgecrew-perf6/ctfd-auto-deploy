#!/bin/bash
[ $(id -u) != "0" ] && { echo "Error: This script must be run as root!"; exit 1; }

Str="abcdefghijklnmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
pass1=""
for i in {1..12}
do
	num=$[RANDOM%${#Str}]
	tmp=${Str:num:1}
	pass1+=$tmp
done
pass2=""
for i in {1..12}
do
	num=$[RANDOM%${#Str}]
	tmp=${Str:num:1}
	pass2+=$tmp
done
pass3=""
for i in {1..12}
do
	num=$[RANDOM%${#Str}]
	tmp=${Str:num:1}
	pass3+=$tmp
done

installDocker(){
    echo "Install Docker"
    a=$(date "+%s")
    curl -sSL https://get.daocloud.io/docker | sh
    curl -SL https://hub.fastgit.xyz/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o /usr/bin/docker-compose
    chmod +x /usr/bin/docker-compose
    systemctl enable docker
    systemctl start docker
    docker swarm init --advertise-addr 127.0.0.1
    docker node update --label-add='name=linux-1' $(docker node ls -q)
    b=$(date "+%s")
    echo "Docker Install Finish. Time: $(($b-$a))s"
}

downloadCtfd(){
    echo "Download Ctfd"
    git clone --depth 1 -b 3.4.3 https://hub.fastgit.xyz/CTFd/CTFd .
    git clone --depth 1 https://hub.fastgit.xyz/frankli0324/ctfd-whale CTFd/plugins/ctfd-whale
    git clone --depth 1 https://hub.fastgit.xyz/liuxin2020/ctfd-plugin-multichoice CTFd/plugins/ctfd-plugin-multichoice
    echo "flask_apscheduler" >> requirements.txt
    curl -fsSL https://raw.fastgit.org/frankli0324/ctfd-whale/master/docker-compose.example.yml -o docker-compose.yml
}

configureCtfd(){
    echo "Configure Ctfd"
    sed -i "s/http:\/\/frpc:7400/http:\/\/${pass1}:${pass2}@frpc:7000/g" /opt/ctfd/CTFd/plugins/ctfd-whale/utils/setup.py
    sed -i "s/frank/${pass1}/g" /opt/ctfd/docker-compose.yml
    sed -i "s/qwer/${pass2}/g" /opt/ctfd/docker-compose.yml
    sed -i "s/your_token/${pass3}/g" /opt/ctfd/docker-compose.yml
    sed -i 's/ctfd_frp-containers/ctfd_containers/g' /opt/ctfd/CTFd/plugins/ctfd-whale/utils/docker.py
    read -p "Enter node domain [127.0.0.1.nip.io]:" domain
    [ ! -n "${domain}" ] && { domain="127.0.0.1.nip.io"; }
    sed -i "s/127.0.0.1.nip.io/${domain}/g" /opt/ctfd/docker-compose.yml
    sed -i "s/127.0.0.1.xip.io/${domain}/g" /opt/ctfd/CTFd/plugins/ctfd-whale/utils/setup.py
    sed -i "s/\"127.0.0.1\"/\"${domain}\"/g" /opt/ctfd/CTFd/plugins/ctfd-whale/utils/setup.py
    sed -i "s/\"127.0.0.1\"/\"${domain}\"/g" /opt/ctfd/CTFd/plugins/ctfd-whale/utils/routers/frp.py
    read -p "Enter node http mode port [8080]:" httpPort
    [ ! -n "${httpPort}" ] && { httpPort="8080"; }
    sed -i "s/8080:8080/${httpPort}:8080\n      - 10000-10100:10000-10100/g" /opt/ctfd/docker-compose.yml
    sed -i "s/8080/${httpPort}/g" /opt/ctfd/CTFd/plugins/ctfd-whale/utils/setup.py
    read -p "Enter node direct mode port range [10000-10100]:" directPort
    [ ! -n "${directPort}" ] && { directPort="10000-10100"; }
    sed -i "s/10100/${directPort#*-}/g" /opt/ctfd/docker-compose.yml
    sed -i "s/10000/${directPort%-*}/g" /opt/ctfd/docker-compose.yml
    sed -i "s/10100/${directPort#*-}/g" /opt/ctfd/CTFd/plugins/ctfd-whale/utils/setup.py
    sed -i "s/10000/${directPort%-*}/g" /opt/ctfd/CTFd/plugins/ctfd-whale/utils/setup.py
}

runCtfd(){
    echo "Run Ctfd"
    docker-compose build
    docker-compose up -d
    echo "ALL DONE"
}

apk --no-cache add git
apt update
apt install -y git
yum makecache
yum -y remove httpd
yum -y install git
docker-compose -f /opt/ctfd/docker-compose.yml down
rm -rf /opt/ctfd
mkdir -p /opt/ctfd
cd /opt/ctfd
installDocker
downloadCtfd
configureCtfd
runCtfd
