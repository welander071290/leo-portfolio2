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

After installing LXC, containers can be made. 
The command 
```
"lxc-create -n "container name" -t download --d alpine -r 3.4 -a armhf" 
```
is used to create a container, and the container is started afterwards with the command 
```
"lxc-start -n "container name"".
```
You now have two options. Attach to the container, or stay "outside" the container.
If you do not attach, the line 
```
lxc-attach -n "container name" --
```
should be written in front of the next commands.
To attach just write 
```
lxc-attach -n "container name"
```
If you ever forget your container name, you can get a list of containers created on you system by writing 
```
"lxc-ls"
```
To make the container up to date, the package list needs to be updated.
Afterwards you are able to install the necessary software.

Write 
```
apk update
```
Now install lighttpd server and som php-packages for the html part.

write 
```
apk add lighttpd php5 php5-cgi php5-curl php5-fpm 
```
for getting the 5 packages needed.

Next enable "fastcgi protocol" by removing the comment (#) sign in /etc/lighttpd/lighttpd.conf

REMEMBER, THIS IS STILL INSIDE THE CONTAINER!

You are now ready to start the lighttpd service by writing 
```
rc-update add lighttpd default 
```
and afterwards 
```
openrc
```

### Web server

You should now create a html ducoment, to be able to communicate between the two containers.
Create a file named "index.php" inside /var/www/localhost/htdocs/  
write
```
nano /var/www/localhost/htdocs/index.php
```
to open up nano text-editor, and inside the document write:

```
<!DOCTYPE html>
<html><body><pre>
<?php 
$ch = curl_init(); 
curl_setopt($ch, CURLOPT_URL, "C2:8080"); 
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
$output = curl_exec($ch);
curl_close($ch);
print $output;
?>
</body></html>
```

"curl_init" is used to initialize cURL for transfering data from or to a server.

"curl_setopt" is used to set the adress of container C2, which is the one we are communicating with.

"curl_exec" is retriewing and printing the URL.

"curl_close" is used to close the cURL afterwards.


### Port forwarding
To make web server in container C1 available to the outside, we're using the built-in firewall utility *iptables* to forward all requests on port 80 of the host to port 80 of C1:

```
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT --to 10.0.3.11:80
```

This is done automatically when running the portfolio2.sh script.

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
**scripts/portfolio2.sh**: Script that starts the containers, forwards port 80 from the host to C1 and serves the random-script on port 8080 on C2.
**scripts/setup_lxc.sh**: Script to install and configure LXC for unprivileged containers and set up an independent network bridge
**scripts/setup_C2.sh**: Script to create container 2 and setup a TCP listener on port 8080
**scripts/random.sh**: Script that returns a random number
