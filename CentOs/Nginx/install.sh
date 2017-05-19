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
yum -y remove varnish

#Install Packages & Libraries
rpm -ivh https://dl.fedoraproject.org/pub/epel/6/x86_64/jemalloc-3.6.0-1.el6.x86_64.rpm
rpm -ivh https://repo.varnish-cache.org/redhat/varnish-4.0.el6.rpm
yum -y install lynx

#Install Varnish Cache
yum -y install varnish

#Config Varnish Cache
cd /etc/varnish/
ip=$(( lynx --dump cpanel.net/showip.cgi ) 2>&1 | sed "s/ //g")
sed -i "s#host = \"127.0.0.1\"#host = \"$ip\"#g" ./default.vcl


cp -p /usr/local/directadmin/data/templates/nginx_server.conf /usr/local/directadmin/data/templates/custom/nginx_server.conf 
cp -p /usr/local/directadmin/data/templates/nginx_server_sub.conf /usr/local/directadmin/data/templates/custom/nginx_server_sub.conf
cd /usr/local/directadmin/data/templates/custom
sed -i 's/proxy_pass |IP|:|PORT_8080|;/proxy_pass |IP|:6081;/g' *


#Config Varnish Cache
cd /etc/sysconfig/
wget https://raw.githubusercontent.com/csabyka/Varnish-Directadmin/master/varnish

#backend default {
#    .host = "127.0.0.1";
#    .port = "8080";
#}

# web -> nginx -> varnish -> apache
# web ->   80  ->  6081   ->  8080
 
#Start Varnish Cache
service httpd restart
service varnish start

#Start When Reboot
chkconfig varnish on

echo -e "$GREEN---------------------------------------------------$RESET"
echo -e "$GREEN      Varnish Cache Install Completed       $RESET"
echo -e "You can monitor varnish cache with command:$GREEN varnishstat $RESET"
echo -e "You can check log varnish cache with command:$GREEN varnishlog $RESET"
echo -e "If have anything problem or bug. Please contact to Github: https://github.com/jazz1611/Varnish-Directadmin"
echo -e "$GREEN---------------------------------------------------$RESET"
