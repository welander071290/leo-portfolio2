#!/bin/bash

echo "Starting container C1."
lxc-start -n C1
echo "Starting container C2."
lxc-start -n C2
#echo "Forwarding port 80 on eth0 to C1."
#sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to 10.0.3.11:80
echo "Forwarding port 80 on wlan0 to C1."
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT --to 10.0.3.11:80
echo "C2 listening on TCP port 8080 and handing out random numbers..."
lxc-attach -n C2 -- /root/start_tcp.sh
