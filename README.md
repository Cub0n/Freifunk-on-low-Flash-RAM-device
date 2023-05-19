# Freifunk for low Flash/Mem devices (old hardware)

## Forewords
* The instruction is not complete and may have some errors and the installation itself is very tricky.
* **Knowledge of configuring and compiling OpenWrt for the target device is required!**
* Images for different router and/or packages will not be provided and has to be self-compiled.
* The whole process can take several hours. The whole instruction and process is just a proof of concept to install Freifunk on old hardware.
* Several steps can be simplified and/or enhanced ... let's see when it's time for that ...

## Idea
* Configure image with block-mount and the needed packages as modules to mount a USB device
* Compile Freifunk Gluon
* Boot the small image and prepare USB device (establish overlay)
* Boot again and install the remaining packages

## Prerequisits
* Linux PC
* "Old" router with USB Port where OpenWRT can be installed
* USB device, formatted with ext4 (1Gb capacity is sufficient)
* (Home) Network
* (Temporary) WebServer on the same subnet (WebServer like https://pythonbasics.org/webserver/ is sufficient). OpenWRT was not able to request packages from a webserver which was not on the same subnet. No idea why. Check if a all ports are accessible to WebServer; Perhaps there is a firewall in place (ufw, firewalld, etc)

## Instructions
* Build Docker container (see Docker directory)
* Adjust the git-gluon-repo-path and start the docker container
* Clone Freifunk Gluon (git clone https://github.com/freifunk-gluon/gluon.git gluon -b RELEASE)
* Clone one Freifunk-Site as described [here](https://gluon.readthedocs.io/en/latest/user/getting_started.html#building-the-images)
* Adjust site config if necessary (see _site.mk_ and _site.conf_ in gluon/site directory)
* Change to gluon repo and execute _make update_
* Change to subdirectory openwrt and execute _make menuconfig_
* Change device model and subtarget
* Change every package and kernel module **which are not needed to mount a USB device** as module (This will take very long and has to be adjusted for every device). Not needed packages are all dealing with Wifi, dnsmasq, lua, etc.
* Select at least busybox, dropbear, block-mount, kmod-fs-ext4, kmod-uhci/ohci, and all applicatons necessary to run a minmal OpenWRT to compile inside the image (see https://openwrt.org/docs/guide-user/additional-software/extroot_configuration)
* Select the needed Freifunk packages as modules
* Exit and save configuration
* Execute _make_, this will download, extract, compile and build the image and all selected packages
* The resulting image and packages are located under _gluon/openwrt/bin/targets/_ and should be smaller than 4MB. If not, repeat the steps to select and mark applications as modules
* Leave the docker container
* Plug the formatted ext4 USB device into the router
* Select the image and flash the router (this can differ for every device), the network cable has to be plugged in a LAN port
* The system should power up and login is possible
* Copy _preinstall.sh_ to router and execute the script (same as https://openwrt.org/docs/guide-user/additional-software/extroot_configuration#configuring_extroot and https://openwrt.org/docs/guide-user/additional-software/extroot_configuration#transferring_data)
* Reboot the router
* The system is powered up and the USB device is used as main drive
* Change to package directory on your PC and start the WebServer or copy all packages to a WebServer directory
* Login to your router
* Adjust opkg URLs on the router to download the compiled packages from the local WebServer
* Execute _opkg update_
* Execute _opkg install gluon-core ip6tables-zz-legacy gluon-ebtables-limit-arp gluon-web-wifi-config gluon-config-mode-geo-location-osm gluon-config-mode-mesh-vpn gluon-mesh-vpn-tunneldigger gluon-ebtables-source-filter hostapd-mini gluon-status-page gluon-config-mode-geo-location gluon-ebtables-filter-multicast gluon-web-autoupdater gluon-status-page-mesh-batman-adv gluon-web-network gluon-web-private-wifi gluon-radvd gluon-config-mode-hostname gluon-respondd gluon-radv-filterd gluon-ebtables-filter-ra-dhcp gluon-mesh-batman-adv-15 gluon-config-mode-autoupdater gluon-autoupdater gluon-config-mode-outdoor gluon-config-mode-contact-info gluon-web-admin respondd-module-airtime iwinfo_ and other packages needed for Freifunk
* Adjust some Freifunk settings (disable autoupdater, set hostname, location, owner), e.g.
  * uci set autoupdater.settings.enabled='0'
  * uci set autoupdater.settings.branch='stable'
  * uci commit autoupdater
  * pretty-hostname 'HOSTNAME'
  * uci set system.@system[0].hostname='HOSTNAME'
  * uci commit system
  * uci set gluon-node-info.@owner[0]='owner'
  * uci set gluon-node-info.@owner[0].contact='email@adress.org'
  * uci commit gluon-node-info
  * uci set gluon-node-info.@location[0]='location'
  * uci set gluon-node-info.@location[0].share_location='1'
  * uci set gluon-node-info.@location[0].latitude='1.1'
  * uci set gluon-node-info.@location[0].longitude='1.1'
  * uci commit gluon-node-info
* Change root password (_passwd root_) The login via SSH and password is disabled after the installation. To reactivate it, change it.
* Reboot
* After restart, the Freifunk device will automatically connect to the configured remote site (Change Network cable from LAN to WAN Port, the firewall is active on WAN port)

## Issues
* The whole process is very error-prone.
* The local WebServer is needed due to the installation of the additional packages. It is possible to copy the packages directly to the USB device and install it from there (change opkg URL to something like: _file:///packages/_ )
* The whole process could be simplified if the configuration is supported inside the Gluon Framwork.
* Cloning Gluon and then the freifunk site should match, otherwise you encounter some build or configuration errors, if the site config does not support an actual gluon framwork
* The router can be very slow and will not handle many Wi-Fi devices, especially if the router has low flash and memory (4MB/32MB)
