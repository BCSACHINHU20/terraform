#!/bin/bash
yum install apache2
yum install epel-release yum-utils wget
wget http://wordpress.org/latest.tar.gz
sudo yum install php-gd
tar xzvf latest.tar.gz
sudo rsync -avP ~/wordpress/ /var/www/html/
mkdir /var/www/html/wp-content/uploads
sudo chown -R apache:apache /var/www/html/*
cd /var/www/html
cp wp-config-sample.php wp-config.php
nano wp-config.php