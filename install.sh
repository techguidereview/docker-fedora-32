#!/bin/bash
# Install Docker-Compose & Wordpress on Fedora 32
# created by: TechGuideReview
set -x # echo on

### install docker from dnf ###
dnf install docker -y

### create docker user group ###
groupadd docker

### add run permissions to the current user ###
usermod -aG docker $SUDO_USER

### run docker service on boot ###
systemctl enable docker.service

### get docker compose ###
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

### apply permissions docker compose ###
chmod +x /usr/local/bin/docker-compose

### create directory in Documents for the compose file ###
mkdir /opt/docker

### populate docker compose file ###
echo "version: '3.3'

services:
   db:
     image: mysql:5.7
     volumes:
       - db_data:/var/lib/mysql
     restart: always
     environment:
       MYSQL_ROOT_PASSWORD: somewordpress
       MYSQL_DATABASE: wordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD: wordpress

   wordpress:
     depends_on:
       - db
     image: wordpress:latest
     ports:
       - "8000:80"
     restart: always
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: wordpress
       WORDPRESS_DB_PASSWORD: wordpress
       WORDPRESS_DB_NAME: wordpress
volumes:
    db_data: {}
" > /opt/docker/docker-compose.yml

### apply kernel mod ###
grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"

### change firewalld to iptables ###
sed -i 's/FirewallBackend=nftables/FirewallBackend=iptables/g' /etc/firewalld/firewalld-workstation.conf

