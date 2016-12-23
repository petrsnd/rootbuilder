#!/bin/sh

if [ ! -f "/etc/ppp/peers/rpivpn" ]; then
    echo -e "VPN gateway is not configured\n"
else
    echo -e "VPN gateway already configured\n"
    echo "Peer configuration:"
    cat /etc/ppp/peers/rpivpn
    read -n1 -p "Would you like to reconfigure? (y/n): " ans
    if ! [[ $ans ~= "[Yy]" ]]; then
        exit 0
    fi
fi

VpnAddress=
while [ -z "$VpnAddress" ]; do
    read -p "VPN address: " VpnAddress
    if ! [[ $VpnAddress =~ ^((1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])$ ]]; then
        >&2 echo "$NewIp must be a valid IP address"
        VpnAddress=
    fi
done

UserName=
read -p "VPN username: " UserName

Password=
read -s -p "Password: " Password
>&2 echo

echo -e "\nOverwriting peer configuration"
sudo cat <<EOF > /etc/ppp/peers/rpivpn
pty "pptp $VpnAddress --nolaunchpppd"
name $(echo $UserName | sed -e 's,\\,\\\\,')
remotename PPTP
require-mppe-128
file /etc/ppp/options.pptp
ipparam rpivpn
usepeerdns
EOF

echo "Writing the credential file"
sudo sed -i -e '/PPTP/d' /etc/ppp/chap-secrets
sudo echo -e "$(echo $UserName | sed -e 's,\\,\\\\,') PPTP $Password *" >> /etc/ppp/chap-secrets
