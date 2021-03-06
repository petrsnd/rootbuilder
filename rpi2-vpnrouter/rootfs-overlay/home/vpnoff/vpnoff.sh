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
    sudo screen -r "rpivpn" -X stuff $'sudo poff rpivpn\n'
    sleep 3
else
    echo -e "VPN does not appear to be running\n"
fi

echo -e "Tearing down screen session\n"
sudo screen -r "rpivpn" -p 0 -X quit

echo -e "Sleeping for 3 seconds...\n"
sleep 3

echo -e "\nVerifying configuration\n"
echo "Looking for ppp interface:"
sudo ifconfig ppp0
echo "Hopefully ppp interface doesn't exist! ;)"
