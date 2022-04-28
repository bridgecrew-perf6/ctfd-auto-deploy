#!/bin/bash
[ $(id -u) != "0" ] && { echo "Error: This script must be run as root!"; exit 1; }

installDocker(){
    echo "Install Docker"
    a=$(date "+%s")
    curl -sSL https://get.daocloud.io/docker | sh
    curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o /usr/bin/docker-compose
    chmod +x /usr/bin/docker-compose
    docker swarm init
    docker node update --label-add='name=linux-1' $(docker node ls -q)
    b=$(date "+%s")
    echo "Docker Install Finish. Time: $(($b-$a))s"
}

downloadCtfd(){
    echo "Download Ctfd"
    git clone --depth 1 -b 3.4.3 https://github.com/CTFd/CTFd .
    git clone --depth 1 https://github.com/frankli0324/ctfd-whale CTFd/plugins/ctfd-whale
    echo "flask_apscheduler" >> requirements.txt
    curl -fsSL https://cdn.jsdelivr.net/gh/frankli0324/ctfd-whale/docker-compose.example.yml -o docker-compose.yml
}

configureCtfd(){
    echo "Configure Ctfd"
    sed -i 's/http:\/\/frpc:7400/http:\/\/frank:qwer@frpc:7000/g' /opt/ctfd/CTFd/plugins/ctfd-whale/utils/setup.py
    sed -i 's/ctfd_frp-containers/ctfd_containers/g' /opt/ctfd/CTFd/plugins/ctfd-whale/utils/docker.py
    # TODO
    # read -p "enter node domain: (e.g. node1.example.com)"  domain
    # read -p "enter node http mode port: (e.g. 8080)"  httpPort
    # read -p "enter node direct mode port range: (e.g. 10000-10100)"  directPort
}

runCtfd(){
    echo "Run Ctfd"
    docker-compose build
    docker-compose up -d
    echo "ALL DONE"
}

docker-compose -f /opt/ctfd/docker-compose.yml down
rm -rf /opt/ctfd
mkdir -p /opt/ctfd
cd /opt/ctfd
installDocker
downloadCtfd
configureCtfd
runCtfd