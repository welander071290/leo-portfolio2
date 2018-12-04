#!/bin/bash

#####################################################
# Bash shell script to generate a random number
#
# Author:
# Anders Welander
#####################################################

if lxc-create -n C2 -t download -- -d alpine -r 3.4 -a armhf ; then
echo "Linux container C2 was created succesfully"
lxc-start -n C2
else
echo "The container could not be created, this program will terminate"
exit 1
fi

lxc-attach -n C2 --
echo "You are now working inside the container"
apk update

lxc-attach -n C2 -- socat -v -v tcp-listen:8080,fork,reuseaddr exec:/bin/random.sh

