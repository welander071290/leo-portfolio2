# Portfolio 2 for the course Linux for Embedded Objects
This repository serves as the second portfolio for the course *Linux for Embedded Objects* during the 5th semester of the Electronics and Computer Engineering education at the University of Southern Denmark.
The assignment is to be implemented on a RaspberryPi Zero running the Raspbian Stretch Lite operating system.

## Assignment specifications
* Create two unprivileged containers
* Enable networking between the containers and the host
* One container should run a web server and be available to the outside
* The other container should run a service which can provide random numbers to the first container

## Solution

### Containers
Containers are created using LXC (https://linuxcontainers.org/). To install LXC from the official repositories run the following commands:

```
sudo apt-get update
sudo apt-get install lxc -y
```

Next, to be able to create [unprivileged containers](https://help.ubuntu.com/lts/serverguide/lxc.html) it is necessary to specify uid/gid mappings and network settings for default containers, and allow them to use the host's network interface. Create the file ~/.config/lxc/default.conf with the following configuration:

```
lxc.id_map = u 0 100000 65536
lxc.id_map = g 0 100000 65536
lxc.network.type = veth
lxc.network.link = lxcbr0
```

Note, the values 100000 and 65536 should match to your user's uid and gid ranges specified in /etc/subuid and /etc/subgid.

Then create the file /etc/lxc/lxc-usernet with the following line:

```
pi veth lxcbr0 10
```

where pi is your username.

Lastly, to [set up an independent network bridge](https://wiki.debian.org/LXC/SimpleBridge) between the host and the containers, create the file /etc/default/lxc-net with the following configuration:

```
USE_LXC_BRIDGE="true"
LXC_BRIDGE="lxcbr0"
LXC_ADDR="10.0.3.1"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="10.0.3.0/24"
LXC_DHCP_RANGE="10.0.3.2,10.0.3.254"
LXC_DHCP_MAX="253"
LXC_DHCP_CONFILE=""
LXC_DOMAIN=""
```
Then start the created lxc-net service:

```
systemctl enable lxc-net
systemctl start lxc-net
```

Then simply log out and log back in for the changes to take effect. Now it is possible to create unprivileged containers.

All of the above is done automatically by running the shell script *setup_lxc.sh* in the scripts folder.

### Web server

### Port forwarding

### Scripts

## Files in the repository
