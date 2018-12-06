# Portfolio 2 for the course Linux for Embedded Objects
This repository serves as the second portfolio for the course *Linux for Embedded Objects* during the 5th semester of the Electronics and Computer Engineering education at the University of Southern Denmark.
The assignment is to be implemented on a RaspberryPi Zero running the Raspbian Stretch Lite operating system.

## Assignment specifications
* Create two unprivileged containers
* Enable networking between the containers and the host
* One container should run a web server and be available to the outside
* The other container should run a service which can provide random numbers to the first container

## Solution

### Setting up LXC
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

Note, the values 100000 and 65536 should match your user's uid and gid ranges specified in /etc/subuid and /etc/subgid.

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
Then start the created lxc-net file as a service:

```
systemctl enable lxc-net
systemctl start lxc-net
```

Then simply log out and log back in for the changes to take effect. It should now be possible to create unprivileged containers.

All of the above is done automatically by running the shell script *scripts/setup_lxc.sh*.

### Containers
To setup containers LXC is used, as mentioned above. 
´´´
$lxc-create -n name_of_container -t download -- -d alpine -r 3.4 -a armhf
´´´
What this line of code does, is creating the container. -t download is a template where the linux version is specified via the template options. Which i this case is the alpine version off linux with the version and the processor architecture also selected in the options.
When the container is created, we start it and goes in to the container to update the packages and install the nessesary programs.
´´´
$lxc-start -n name_of_container
$lxc-attach -n name_of_container --apk update
´´´

### Web server

### Port forwarding

### Scripts
The random script contains the following command

´´´
dd if=/dev/random bs=4 count=1 status=none | od -A none -t u4
´´´
dd; is a 'convert and copy' command. it's primarily used to copy files to devices, such as a usb-stick.
if; specifie where to copy the file from, in this case it copies the number random.
bs; is the block size in BYTES.
count; is how many blocks is copies.
status=none; displays only error messages.

All this is piped over to od, which convert the input to a specified output.
-A none; decide how file offsets are printed, it is not specified further.
-t u4; is the format, in this case i is unsigned decimal 4-byte units.

## Files in the repository
**scripts/setup_lxc.sh**: Script to install and configure LXC for unprivileged containers and set up an independent network bridge
**scripts/setup_C2.sh**: Script to create container 2 and setup a TCP listener on port 8080
**scripts/random.sh**: Script that returns a random number
