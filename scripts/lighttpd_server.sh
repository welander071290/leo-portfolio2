#!/bin/bash

#####################################################
# Bash shell script to automatically installing and
# starting "lighttpd" webserver in container
#
# Author:
# Rasmus Ørbech
#####################################################

# Checks if a container by this name already exists
if lxc-ls | grep C1 ; then
	echo "A container by this name already exists."
	exit 1
else
	echo "Creating container C1"

	
# Code for creating container
	echo "Creating container..."
	lxc-create -n C1 -t download -- -d alpine -r 3.4 -a armhf
# Skulle virke
	
	
	
# Start container
	lxc-start -n C1
	echo "Updating package list and install needed packages..."
# Skulle virke
	
	
# Updating package list
	lxc-attach -n C1 -- apk update
	echo "Package list updated"
# Skulle virke
	
	
# Install needed packages	
	lxc-attach -n C1 -- apk add lighttpd php5 php5-cgi php5-curl php5-fpm
	echo "Needed packages installed with success!"
# Skulle virke	
	
	
# Enable "fastcgi" in dokument /etc/lighttpd/lighttpd.conf
	lxc-attach -n C1 -- sed -i -e 's/#   include "mod_fastcgi.conf"/include "mod_fastcgi.conf"/g' /etc/lighttpd/lighttpd.conf
# Skulle virke


	echo "Starting the lightTPD service"
# Start the lighttpd service	
	lxc-attach -n C1 -- rc-update add lighttpd default
	lxc-attach -n C1 -- openrc
fi

echo "All done, server running"
	
echo "Creating /var/www/localhost/htdocs/index.php"

lxc-attach -n C1 -- touch /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '01i\<!DOCTYPE html>' /var/www/localhost/htdocs/index.php 
lxc-attach -n C1 -- sed -i '02i\<html><body><pre>' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '03i\<<?php' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '04i\<// create curl resource' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '05i\<$ch = curl_init();' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '06i\// set url' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '07i\<curl_setopt($ch, CURLOPT_URL, "C2:8080");' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '08i\//return the transfer as a string' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '09i\curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '10i\// $output contains the output string' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '11i\$output = curl_exec($ch);' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '12i\// close curl resource to free up system resources' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '13i\curl_close($ch);' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '14i\print $output;' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '15i\?>' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '16i\</body></html>' /var/www/localhost/htdocs/index.php
lxc-attach -n C1 -- sed -i '17i\<!DOCTYPE html>' /var/www/localhost/htdocs/index.php 
 
echo "Done creating /var/www/localhost/htdocs/index.php"

exit 0

