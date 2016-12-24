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
