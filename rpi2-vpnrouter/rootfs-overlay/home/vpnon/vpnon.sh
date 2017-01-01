#!/bin/sh

if [ ! -f "/etc/ppp/peers/rpivpn" ]; then
    echo "VPN gateway is not configured"
    echo -e "You must configure the VPN gateway using ssh as the vpnsetup user\n"
    read -p "Press enter key..." X
    exit 1
fi

sudo screen -list | grep -q "rpivpn"
if [ $? -eq 0 ]; then
    echo -e "Found an existing screen session, kill it using vpnoff user"
    exit 1
fi

echo -e "Enabling VPN gateway\n"
sudo screen -S "rpivpn" -d -m
sudo screen -r "rpivpn" -X stuff $'sudo pon rpivpn debug dump logfd 2\n'

echo -e "Sleeping for 5 seconds...\n"
sleep 5

echo -e "\nVerifying configuration\n"
echo "ip forwarding:"
sudo sysctl net.ipv4.ip_forward
echo -e "\nLooking for ppp interface:"
sudo ifconfig ppp0
echo -e "\niptables configuration:"
sudo iptables -L -n -v
echo -e "\niptables nat configuration:"
sudo iptables -t nat -L -n -v
echo -e "\nresolver configuration:"
sudo cat /etc/resolv.conf
