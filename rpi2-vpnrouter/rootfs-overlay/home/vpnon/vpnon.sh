#!/bin/sh

if [ ! -f "/etc/ppp/peers/rpivpn" ]; then
    echo "VPN gateway is not configured"
    echo -e "You must configure the VPN gateway using ssh as the vpnsetup user\n"
    read -p "Press enter key..." X
    exit 1
fi

if ! sudo screen -list | grep -q "rpivpn"; then
    sudo screen -r "rpivpn" -p 0 -X quit
fi

echo -e "Enabling VPN gateway\n"
sudo screen -S "rpivpn" -d -m
sudo screen -r "rpivpn" -X stuff $'sudo pon rpivpn debug dump logfd 2\n'

echo -e "Sleeping for 5 seconds...\n"
sleep 5

echo -e "\nVerifying configuration\n"
echo "Looking for ppp interface:"
sudo ifconfig ppp0
echo -e "\niptables configuration:"
sudo iptables -L
