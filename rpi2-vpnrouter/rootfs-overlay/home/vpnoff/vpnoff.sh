#!/bin/sh

if [ ! -f "/etc/ppp/peers/rpivpn" ]; then
    echo "VPN gateway is not configured"
    echo -e "You must configure the VPN gateway using ssh as the vpnsetup user\n"
    read -p "Press any key..." X
    exit 1
fi

if ! sudo screen -list | grep -q "rpivpn"; then
    echo -e "Disabling VPN\n"
    sudo screen -S "rpivpn" -d -m
    sudo screen -r "rpivpn" -X stuff $'sudo poff\n'
    sudo screen -r "rpivpn" -p 0 -X quit
else
    echo -e "VPN does not appear to be running\n"
fi

echo -e "\nVerifying configuration\n"
echo "Looking for ppp interface:"
sudo ifconfig ppp0
echo -e "\niptables configuration:"
sudo iptables -L
