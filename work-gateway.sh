#!/bin/bash
## This script is meant to work with the rpiX-vpnrouter to setup
## a Mac to use it

WORK_DNS_SERVER=10.5.33.37
GATEWAY=$(dig +short rpi2)
if [ ! -z "$GATEWAY" ]; then
    echo $GATEWAY > /tmp/gateway
else
    GATEWAY=$(cat /tmp/gateway)
fi
REMOTENETWORK="10.0.0.0/8"

print_usage()
{
    cat <<EOF
USAGE: work-gateway.sh {on|off} [gateway-ip]
  on     Turn on the work gateway through specified IP address
  off    Turn off the work gateway and restore normal networking
  setup  Setup the work gateway by configuring it to use the VPN
EOF
    exit 0
}

if [ -z "$1" ]; then print_usage; fi
if [ -z "$2" ]; then
    if [ -z "$GATEWAY" ]; then
        echo "Unable to determine gateway-ip"
        exit 1
    fi
    echo -e "gateway-ip set to default $GATEWAY\n"
else
    echo "Parameter for gateway specified"
    GATEWAY=$2
fi

echo "Using GATEWAY=$GATEWAY"
if [ "$1" = "on" ]; then
    echo "Turning on gateway via ssh"
    ssh vpnon@$GATEWAY
    if [ $? -ne 0 ]; then
        echo "Unable to setup gateway on $GATEWAY"
        exit 1
    fi
    echo -e "\nSetting route for $REMOTENETWORK to $GATEWAY"
    sudo route -n add $REMOTENETWORK $GATEWAY
    echo "Setting DNS servers to $WORK_DNS_SERVER"
    sudo networksetup -setdnsservers Wi-Fi $WORK_DNS_SERVER
    sudo networksetup -setdnsservers "AX88179 USB 3.0 to Gigabit Ethernet" $WORK_DNS_SERVER
elif [ "$1" = "off" ]; then
    ssh vpnoff@$GATEWAY
    if [ $? -ne 0 ]; then
        echo "Unable to remove gateway on $GATEWAY"
    fi
    echo "Deleting route for $REMOTENETWORK"
    sudo route -n delete $REMOTENETWORK
    echo "Restoring DNS servers to DHCP configuration"
    sudo networksetup -setdnsservers Wi-Fi Empty
    sudo networksetup -setdnsservers "AX88179 USB 3.0 to Gigabit Ethernet" Empty
elif [ "$1" = "setup" ]; then
    ssh vpnsetup@$GATEWAY
    if [ $? -ne 0 ]; then
        echo "Unable to setup gateway on $GATEWAY"
    fi
else
    echo -e "Unrecognized argument: $1"
    print_usage
fi

