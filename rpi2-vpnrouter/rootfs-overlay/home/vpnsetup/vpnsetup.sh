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

echo -e "\nOverwriting peer configuration"
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
sudo echo -e "$(echo $UserName | sed -e 's,\\,\\\\,') PPTP $Password *" | sudo tee -a /etc/ppp/chap-secrets > /dev/null
