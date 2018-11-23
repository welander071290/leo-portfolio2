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
else
	echo -n "Installing LXC... "
	sudo apt-get install lxc -y > /dev/null
	if [ $? = 0 ]
	then
		echo "LXC installed succesfully!"
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
echo "$USER veth lxcbr0 10" | sudo tee /etc/lxc/lxc-usernet > /dev/null

echo "Created ~/.config/lxc/default.conf and /etx/lxc/lxc-usernet."

# Add user to required cgroups
# https://github.com/NixOS/nixpkgs/issues/25754
echo -n "Adding current user to required cgroups... "

for d in /sys/fs/cgroup/*; do
        f=$(basename $d)
        if [ "$f" = "cpuset" ]; then
                echo 1 | sudo tee -a $d/cgroup.clone_children > /dev/null;
        elif [ "$f" = "memory" ]; then
                echo 1 | sudo tee -a $d/memory.use_hierarchy > /dev/null;
        fi
        sudo mkdir -p $d/$USER
        sudo chown -R $USER $d/$USER
        echo $$ > $d/$USER/tasks
done

echo "Done."

# Set up bridge using lxc-net
# https://wiki.debian.org/LXC/SimpleBridge
echo -n "Setting up network bridge using lxc-net... "

cat << EOF | sudo tee /etc/default/lxc-net > /dev/null
USE_LXC_BRIDGE="true"
LXC_BRIDGE="lxcbr0"
LXC_ADDR="10.0.3.1"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="10.0.3.0/24"
LXC_DHCP_RANGE="10.0.3.2,10.0.3.254"
LXC_DHCP_MAX="253"
LXC_DHCP_CONFILE=""
LXC_DOMAIN=""
EOF

echo "Done."

echo -n "Enabling and restarting lxc-net..."
sudo systemctl enable lxc-net > /dev/null 2>&1
sudo systemctl start lxc-net > /dev/null 2>&1
echo "Done."

echo "LXC succesfully installed and configured for unprivileged containers!"

exit 0