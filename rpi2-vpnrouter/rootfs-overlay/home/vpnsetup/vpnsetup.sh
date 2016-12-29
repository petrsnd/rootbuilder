#!/bin/sh

if [ ! -f "/etc/ppp/peers/rpivpn" ]; then
    echo -e "VPN gateway is not configured\n"
else
    echo -e "VPN gateway already configured\n"
    echo "Peer configuration:"
    sudo cat /etc/ppp/peers/rpivpn
    read -n1 -p "Would you like to reconfigure? (y/n): " ans
    if ! [[ $ans =~ [Yy] ]]; then
        exit 0
    else
        echo -e "\n"
    fi
fi

VpnAddress=
while [ -z "$VpnAddress" ]; do
    read -p "VPN address: " VpnAddress
    if ! [[ $VpnAddress =~ ^((1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])$ ]]; then
        nslookup $VpnAddress > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            >&2 echo "$VpnAddress is not an IP address and doesn't resolve"
            VpnAddress=
        fi
    fi
done

UserName=
read -p "VPN username: " UserName

Password=
read -s -p "Password: " Password
>&2 echo

DnsServers=
echo "List of remote DNS servers; empty string to end list"
while : ; do
    read -p "Remote DNS Server: " DnsServer
    if [ -z "$DnsServer" ]; then
        break
    fi
    if ! [[ $DnsServer =~ ^((1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])$ ]]; then
        echo "Not an IP address, try again"
        continue
    fi
    DnsServers="$DnsServers$DnsServer "
done

RemoteNetwork=
echo "The remote network is needed to set up routing, please use CIDR notation (e.g. 10.0.0.0/8)"
while [ -z "$RemoteNetwork" ]; do
    read -p "Remote network: " RemoteNetwork
    if ! [[ $RemoteNetwork =~ ^((1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])/[0-9]{1,2}$ ]]; then
        echo "Not CIDR notation, please use a valid network such as 10.0.0.0/8"
        RemoteNetwork=
    fi
done


echo -e "\nWriting peer configuration"
sudo cat <<EOF | sudo tee /etc/ppp/peers/rpivpn > /dev/null
pty "pptp $VpnAddress --nolaunchpppd"
name $(echo $UserName | sed -e 's,\\,\\\\,')
remotename PPTP
require-mppe-128
file /etc/ppp/options.pptp
ipparam rpivpn
usepeerdns
EOF

echo "Writing the credential file"
sudo bash -c "sed -i -e '/PPTP/d' /etc/ppp/chap-secrets"
sudo echo "$(echo $UserName | sed -e 's,\\,\\\\,') PPTP $Password *" | sudo tee -a /etc/ppp/chap-secrets > /dev/null

echo "Writing the resolver configuration"
sudo cat <<EOF | sudo tee /etc/ppp/resolv.conf > /dev/null
$(for s in $DnsServers; do echo -e "nameserver $s"; done)
EOF

echo "Writing routing scripts"
sudo cat <<EOF | sudo tee /etc/ppp/ip-up.d/000routing > /dev/null
#!/bin/sh

# Randomly added route??
route del 166.70.162.27

# VPN remote network route
route add -net $RemoteNetwork dev ppp0

# Forwarding for other computers on my LAN
iptables --insert OUTPUT 1 --source 0.0.0.0/0.0.0.0 --destination $RemoteNetwork --jump ACCEPT --out-interface ppp0
iptables --insert INPUT 1 --source $RemoteNetwork --destination 0.0.0.0/0.0.0.0 --jump ACCEPT --in-interface ppp0
iptables --insert FORWARD 1 --source 0.0.0.0/0.0.0.0 --destination $RemoteNetwork --jump ACCEPT --out-interface ppp0
iptables --insert FORWARD 1 --source $RemoteNetwork --destination 0.0.0.0/0.0.0.0 --jump ACCEPT
iptables --table nat --append POSTROUTING --out-interface ppp0 --jump MASQUERADE
iptables --append FORWARD --protocol tcp --tcp-flags SYN,RST SYN --jump TCPMSS --clamp-mss-to-pmtu
EOF
sudo cat <<EOF | sudo tee /etc/ppp/ip-down.d/000routing > /dev/null
#!/bin/sh

# VPN remote network route
route del -net $RemoteNetwork

# Remove forwarding for LAN
iptables -F
iptables -t nat -F
EOF

