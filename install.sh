#!/bin/bash

# This is scripts install Varnish Cache for Directadmin.
### Build by Jazz1611 ###

RED='\033[01;31m'
GREEN='\033[01;32m'
RESET='\033[0m'

#Clear Screen For Install
clear

echo -e "$GREEN----------------------------------------$RESET"
echo -e "  $RED Varnish Cache (Ver 4.x) for Directadmin $RESET"
echo -e "           Version Release: 1.0          "
echo -e "     Build by Jazz1611  "
echo -e "$GREEN----------------------------------------$RESET"

#Check Directadmin Installed
echo -ne "Checking Directadmin Installed..."
if [ -e  "/usr/local/directadmin" ]; then
	echo -e "[ $GREEN Directadmin Found $RESET ]"
else
	echo -e "[ $RED Directadmin Not Found.\n Exiting Install. $RESET ]"
	exit
fi

#Removing Previous Varnish Cache
apt-get remove varnish -y

#Install Packages & Libraries & Varnish Cache
apt-get install apt-transport-https -y
curl https://repo.varnish-cache.org/GPG-key.txt | sudo apt-key add -
echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.1" \
    | sudo tee -a /etc/apt/sources.list.d/varnish-cache.list
apt-get update
apt-get install varnish lynx -y

#configure httpd

cd /etc/httpd/conf/
sed -i 's#Listen 80#Listen 8080#g' ./httpd.conf
cd extra
sed -i "s#:80#:8080#g" ./httpd-vhosts.conf
cp -p /usr/local/directadmin/data/templates/virtual_host2.conf  /usr/local/directadmin/data/templates/custom/virtual_host2.conf
cp -p /usr/local/directadmin/data/templates/virtual_host2_sub.conf  /usr/local/directadmin/data/templates/custom/virtual_host2_sub.conf
cp -p  /usr/local/directadmin/data/templates/redirect_virtual_host.conf  /usr/local/directadmin/data/templates/custom/redirect_virtual_host.conf
cd /usr/local/directadmin/data/templates/custom
sed -i 's/<VirtualHost |IP|:|PORT_80| |MULTI_IP|>/<VirtualHost 127.0.0.1:8080 |IP|:8080 |MULTI_IP|>/g' *

cd /usr/src
wget https://github.com/gnif/mod_rpaf/archive/stable.zip
unzip stable.zip
cd mod_rpaf-stable/
apxs -cia mod_rpaf.c
cd
ip=$(( lynx --dump cpanel.net/showip.cgi ) 2>&1 | sed "s/ //g")
echo "<IfModule mod_rpaf-2.0.c>
RPAFenable On
RPAFsethostname On
RPAFproxy_ips 127.0.0.1 $ip
RPAFheader X-Forwarded-For
</IfModule>" >> /etc/httpd/conf/extra/httpd-rpaf.conf
echo "Include /etc/httpd/conf/extra/httpd-rpaf.conf" >> /etc/httpd/conf/extra/httpd-includes.conf
echo "action=rewrite&value=httpd" >> /usr/local/directadmin/data/task.queue

#Config Varnish Cache
cd /etc/default/
wget https://raw.githubusercontent.com/csabyka/Varnish-Directadmin/master/varnish
ip=$(( lynx --dump cpanel.net/showip.cgi ) 2>&1 | sed "s/ //g")
sed -i "s#VARNISH_LISTEN_ADDRESS=XXXXXX#VARNISH_LISTEN_ADDRESS=$ip#g" ./varnish

#Start Varnish Cache
service httpd restart
service varnish start


echo -e "$GREEN---------------------------------------------------$RESET"
echo -e "$GREEN      Varnish Cache Install Completed       $RESET"
echo -e "You can monitor varnish cache with command:$GREEN varnishstat $RESET"
echo -e "You can check log varnish cache with command:$GREEN varnishlog $RESET"
echo -e "If have anything problem or bug. Please contact to Github: https://github.com/csabyka/Varnish-Directadmin"
echo -e "$GREEN---------------------------------------------------$RESET"
