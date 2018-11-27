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
	sudo lxc-create -c $containername -t download -- -d alpine -r 3.4 -a armhf
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
	
# Disabling "fastcgi"
# Gå ind og ret i linje xxx i dokument /etc/lighttpd/lighttpd.conf
# echo "..." >> /etc/lighttpd/lighttpd.conf

	echo "Starting the lightTPD service"
# Start the lighttpd service	
	sudo rc-update add lighttpd default
	sudo openrc
fi

echo "All done, server rinning"
exit 0	
	

