#!/bin/bash

#####################################################
# Bash shell script to automatically install LXC and
# configure it for using unprivileged containers
#
# Author:
# Kristian Klein Jacobsen
#####################################################

# Test if LXC is already installed, otherwise install it
if dpkg -s lxc > /dev/null 2>&1
then
	echo "LXC is already installed."
	echo ""
else
	echo "Installing LXC..."
	sudo apt-get install lxc -y > /dev/null
	if [ $? = 0 ]
	then
		echo "LXC installed succesfully!"
		echo ""
	else
		echo "Installation failed. Aborting."
		exit 1
	fi
fi

# Configure LXC for unprivileged containers
# https://help.ubuntu.com/lts/serverguide/lxc.html
echo "Setting up LXC for unprivileged containers."

UIDstart=$(grep $USER /etc/subuid | cut -d':' -f2 | head -n1)
UIDlength=$(grep $USER /etc/subuid | cut -d':' -f3 | head -n1)
GIDstart=$(grep $USER /etc/subgid | cut -d':' -f2 | head -n1)
GIDlength=$(grep $USER /etc/subgid | cut -d':' -f3 | head -n1)

echo "User $USER has UIDs $UIDstart:$(( UIDstart + $UIDlength )) and GIDs $GIDstart:$(( GIDstart + GIDlength ))."

mkdir -p ~/.config/lxc
echo "lxc.id_map = u 0 $UIDstart $UIDlength" > ~/.config/lxc/default.conf
echo "lxc.id_map = g 0 $GIDstart $GIDlength" >> ~/.config/lxc/default.conf
echo "lxc.network.type = veth" >> ~/.config/lxc/default.conf
echo "lxc.network.link = lxcbr0" >> ~/.config/lxc/default.conf
echo "$USER veth lxcbr0 2" | sudo tee /etc/lxc/lxc-usernet > /dev/null

# Fix for unprivileged containers not working on specific kernels
# https://askubuntu.com/questions/654722/lxc-is-returning-an-error-when-creating-new-unprivileged-containers
if [ $(cat /proc/sys/kernel/unprivileged_userns_clone) = 0 ]; then
	echo "Kernel does not allow unprivileged containers. Adding fix."
	echo "kernel.unprivileged_userns_clone=1" | sudo tee /etc/sysctl.d/80-lxc-userns.conf > /dev/null
  sudo sysctl --system > /dev/null
fi

echo ""
echo "LXC succesfully installed and configured for unprivileged containers!"

exit 0