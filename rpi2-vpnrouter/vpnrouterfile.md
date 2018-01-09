I built this tool for myself, so there is a built in user account called
dpeterso.  You will want to change this in the file system overlay to
your own user name.

rootfs-overlay/home/dpeterso

You will need to update the wheel group in group file in the overlay as well. 
Add your username in place of dpeterso.

rootfs-overlay/etc/group

If you want to customize for you to manipuate the VPN via SSH, you need to make
sure your SSH public key is in all of the authorized key files listed in
the file system overlay.  You will have a tough time coming up with my private
key.

rootfs-overlay/home/[your username]/.ssh/authorized_keys
rootfs-overlay/home/vpnoff/.ssh/authorized_keys
rootfs-overlay/home/vpnon/.ssh/authorized_keys
rootfs-overlay/home/vpnsetup/.ssh/authorized_keys


In order to get the pon and poff commands working as expected, you need the
follwing root-owned files placed on the file system in addition to those that
are a part of the overlay.

/etc/ppp/
    resolve.conf
    chap-secrets  (MODE should be 600)

/etc/ppp/peers/
    rpivpn

/etc/ppp/ip-up.d/
    000routing

/etc/ppp/ip-down.d/
    000routing


For the most part these files are created by the vpnsetup.sh script.
