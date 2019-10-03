#!/bin/bash
# Custom Script to install Apache and PHP

sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get -y update
export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y install apache2 php7.3 libapache2-mod-php7.3 php7.3-mysql
sudo apt-get -y install php7.3-cli php7.3-fpm php7.3-json php7.3-pdo php7.3-zip php7.3-gd php7.3-mbstring php7.3-curl php7.3-xml php7.3-bcmath php7.3-json
sudo service apache2 start
sudo chkconfig httpd on
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php > /dev/null
