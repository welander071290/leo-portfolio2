#!/bin/bash

#####################################################
# Bash shell script to automatically installing and
# starting "lighttpd" webserver in container
#
# Author:
# Rasmus Ørbech
#####################################################

# Take an input name for the container name
echo Please write a name for the container you are creating
read containername


# Checks if a container by this name already exists
if lxc-ls | grep $containername ; then
	echo "A container by this name already exists."
	exit 1
else
	echo "Creating container $containername"

	
# Code for creating container
	sudo lxc-create -n $containername -t download -- -d alpine -r 3.4 -a armhf
	echo "Starting container..."
# Start container
	sudo lxc-start -n $containername
	sudo lxc-attach -n $containername
	echo "Updating package list and install needed packages..."

# Updating package list
	if sudo lxc-attach -n $containername -- apk update ; then
		echo "Package list updated"
	else 
		echo "Error Updating package list"
		exit 1
	fi
	
# Install needed packages	
	if sudo lxc-attach -n $containername -- apk add lighttpd php5 php5-cgi php5-curl php5-fpm ; then
		echo "Needed packages installed with success!"
	else 
		echo "Error installing needed packages"
		exit 1
	fi
	
# Enable "fastcgi" in dokument /etc/lighttpd/lighttpd.conf
	lxc-attach -n $containername -- sed -i '46i\ include "mod_fastcgi.conf"' /etc/lighttpd/lighttpd.conf

	echo "Starting the lightTPD service"
# Start the lighttpd service	
	rc-update add lighttpd default
	openrc
fi

echo "All done, server running"
	
echo "Creating /var/www/localhost/htdocs/index.php"

lxc-attach -n $containername -- echo "<!DOCTYPE html>" >> /var/www/localhost/htdocs/index.php 
lxc-attach -n $containername -- echo "<html><body><pre>" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "<<?php" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "<// create curl resource" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "<$ch = curl_init();" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "// set url" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "<curl_setopt($ch, CURLOPT_URL, "C2:8080");" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "//return the transfer as a string" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "// $output contains the output string" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "$output = curl_exec($ch);" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "// close curl resource to free up system resources" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "curl_close($ch);" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "print $output;" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "?>" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "</body></html>" >> /var/www/localhost/htdocs/index.php
lxc-attach -n $containername -- echo "<!DOCTYPE html>" >> /var/www/localhost/htdocs/index.php 
 
echo "Done creating /var/www/localhost/htdocs/index.php"

exit 0

