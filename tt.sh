#!/bin/bash

sudo systemctl stop apache2
sudo systemctl stop mariadb
sudo systemctl stop lighttpd
sleep 10
sudo apt purge apache2 apache2-utils apache2-bin apache2.2-common -y
sudo apt autoremove --purge -y
sleep 10
sudo apt purge lighttpd -y
sudo apt autoremove --purge -y
sleep 10
sudo apt purge php* libapache2-mod-php* php-cgi php-fpm -y
sudo apt autoremove --purge -y
sleep 10
sudo systemctl stop mariadb
sudo apt purge mariadb-server mariadb-client mariadb-common mariadb-server-core-* mariadb-client-core-* -y
sudo apt autoremove --purge -y
sleep 10
sudo rm -rf /var/lib/mysql
sudo rm -rf /etc/mysql
sleep 3
sudo rm -rf /etc/apache2
sudo rm -rf /etc/lighttpd
sudo rm -rf /etc/php
sudo rm -rf /var/log/apache2
sudo rm -rf /var/log/lighttpd
sudo rm -rf /var/log/mysql
sleep 2
sudo lsof -i :80
sudo lsof -i :3306
