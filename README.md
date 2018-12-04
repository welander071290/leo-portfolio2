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

After installing LXC, containers can be made. 
The command "lxc-create -n "container name" -t download --d alpine -r 3.4 -a armhf", is used to create a container, 
and the container is started afterwards with the command "lxc-start -n "container name"".

You now have two options. Attach to the container, or stay "outside" the container.
If you do not attach, the line "lxc-attach -n "container name" --" should be written in front of the next commands.
To attach just write "lxc-attach -n "container name""

If you ever forget your container name, you can get a list of containers created on you system by writing "lxc-ls"

To make the container up to date, package list need to be updated.
Afterwards you are able to install the necessary software.

Write "apk update"

Now install lighttpd server and som php-packages for the html part.

write "apk add lighttpd php5 php5-cgi php5-curl php5-fpm" for getting the 5 packages.

Next enable fastcgi protocol by removing the comment (#) sign in /etc/lighttpd/lighttpd.conf

REMEMBER, THIS IS STILL INSIDE THE CONTAINER!

You are now ready to start the lighttpd service by writing "rc-update add lighttpd default" and afterwards "openrc"

### Web server

You should now create a file named "index.php" inside /var/www/localhost/htdocs/  
write "nano /var/www/localhost/htdocs/index.php" and inside the index document write:

&lt;!DOCTYPE html&gt;
&lt;html&gt;&lt;body&gt;&lt;pre&gt;
&lt;?php 
$ch = curl_init(); 
curl_setopt($ch, CURLOPT_URL, "C2:8080"); 
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
$output = curl_exec($ch);
curl_close($ch);
print $output;
?&gt;
&lt;/body&gt;&lt;/html&gt;

### Port forwarding

### Scripts

## Files in the repository
**scripts/setup_lxc.sh**: Script to install and configure LXC for unprivileged containers and set up an independent network bridge

