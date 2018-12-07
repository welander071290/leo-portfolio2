#!/bin/bash

#####################################################
# Bash shell script to generate a random number
#
# Author:
# Anders Welander
#####################################################

if lxc-ls | grep C2 ; then
	echo "C2 already exist"
else
	if lxc-create -n C2 -t download -- -d alpine -r 3.4 -a armhf ; then
		echo "Linux container C2 was created succesfully"
	else
		echo "The container could not be created, this program will terminate"
		exit 1
	fi
fi

lxc-start -n C2
echo "Caontainer started"

#This will try to update 3 times
n=0
	until [ $n -ge 3 ]
	do
		lxc-attach -n C2 -- apk update & break
		n=$[$n+1]
	done

echo "Container C2 is updated"

lxc-attach -n C2 -- apk add socat
echo "Socat installed"


lxc-attach -n C2 -- socat -v -v tcp-listen:8080,fork,reuseaddr exec:/random.sh

exit
