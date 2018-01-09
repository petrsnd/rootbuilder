# rootbuilder

This is a simple project for storing some settings and build environment
details for building some useful embedded Linux kernel images using the tools
from [buildroot.org](https://buildroot.org).

# projects

## usb-linux

Simple, tiny embedded Linux image that can be used to debug or analyze a broken 
machine.  It can be loaded onto a very small USB drive.

Use the `build.sh` script to build the image.

## rpi2-vpnrouter

Apple made the decision to disable their PPTP VPN client. The only PPTP clients
I could find online or in the AppStore were quite expensive.  I wanted a little 
image I could run on my raspberry pi 2 that could connect to the VPN for me and 
then expose the connection as a gateway for my MacBook.  Once the VPN is nailed
up, I just need to make a few local changes to add the static route and add the
DNS server.  Works great to keep working from home until work gets a better VPN
solution put together.

I added a Dockerfile so that I could use the buildroot tools from my MacBook
without having to go nutty downloading tools from HomeBrew.  You don't need to
use the Docker environment on Linux.

The file system overlay has my SSH public key embedded in it, but you could
easily add yours.

### Using the VPN

SSH is the interface to utilizing the VPN.  Make sure your public key to the
authorized_keys file.

1. Setup the VPN configuration

`ssh vpnsetup@<your rpi2>`

Follow the prompts to configure your VPN and gateway to the remote network.

2. Connect the VPN

`ssh vpnon@<your rpi2>`

This will connect the tunnel.  You need to make sure you setup the local static
route.

3. Do your work

4. Disconnect the VPN

`ssh vpnoff@<your rpi2>`

This should pull down the tunnel.  You need to make sure you remove your local
static route.

## rpi3-vpnrouter

This is a version of the above project but built for raspberry pi 3.

Right now I don't have this build working.  I had a raspberry pi 2 lying around
so I did that version first.
