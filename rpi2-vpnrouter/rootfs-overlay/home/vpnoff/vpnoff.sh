#!/bin/sh

if [ ! -f "/etc/ppp/peers/rpivpn" ]; then
    echo "VPN gateway is not configured"
    echo -e "You must configure the VPN gateway using ssh as the vpnsetup user\n"
    read -p "Press any key..." X
    exit 1
fi

echo -e "Disabling VPN\n"
sudo poff

echo -e "\nVerifying configuration\n"
echo "Looking for ppp interface:"
sudo ifconfig ppp0
echo -e "\niptables configuration:"
sudo iptables -L
