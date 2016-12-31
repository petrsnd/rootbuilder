#!/bin/sh

if [ ! -f "/etc/ppp/peers/rpivpn" ]; then
    echo "VPN gateway is not configured"
    echo -e "You must configure the VPN gateway using ssh as the vpnsetup user\n"
    read -p "Press any key..." X
    exit 1
fi

sudo screen -list | grep -q "rpivpn"
if [ $? -eq 0 ]; then 
    echo -e "Disabling VPN\n"
    sudo screen -r "rpivpn" -X stuff $'sudo poff\n'
    sudo screen -r "rpivpn" -p 0 -X quit
else
    echo -e "VPN does not appear to be running\n"
fi

echo -e "Sleeping for 5 seconds...\n"
sleep 5

echo -e "\nVerifying configuration\n"
echo "Looking for ppp interface:"
sudo ifconfig ppp0
echo -e "\niptables configuration:"
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v
echo -e "\nresolver configuration:"
sudo cat /etc/resolv.conf
echo -e "\nip forwarding:"
sudo sysctl net.ipv4.ip_forward
