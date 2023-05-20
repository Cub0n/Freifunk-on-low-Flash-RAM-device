# Freifunk for low Flash/Mem devices (old hardware)

## Forewords
* The instruction is not complete and may have some errors and the installation itself is very tricky.
* **Knowledge of configuring, compiling and flashing OpenWRT for the target device is required!** (see https://openwrt.org/faq/how_do_i_compile_openwrt)
* Images for different router and/or packages will not be provided and has to be self-compiled.
* The whole process can take several hours. The whole instruction and process is just a proof of concept to install Freifunk on old hardware.
* Several steps can be simplified and/or enhanced ... let's see when it's time for that ...

## Idea
* Configure image with block-mount (overlay fs) and the needed packages as modules to mount a USB device
* Compile Freifunk Gluon
* Boot the small image and prepare USB device (establish overlay)
* Boot again and install the remaining packages

## Prerequisites
* Linux PC
* "Old" router with USB Port where OpenWRT can be installed
* USB device, formatted with ext4 (1Gb capacity is sufficient)
* (Home) Network
* (Temporary) web server on the same subnet (web server like https://pythonbasics.org/webserver/ is sufficient). OpenWRT was not able to download packages from a web server which was not on the same subnet. No idea why, perhaps there was no gateway set. Check if a all ports are accessible to web server; Perhaps there is a firewall in place (ufw, firewalld, etc)

## Instructions
* Clone Freifunk Gluon (git clone https://github.com/freifunk-gluon/gluon.git gluon -b RELEASE)
* Clone one Freifunk-Site as described [here](https://gluon.readthedocs.io/en/latest/user/getting_started.html#building-the-images)
* Build Docker container with _gluon/contrib/docker/Dockerfile_
* Opional: Adjust site config if necessary (see _site.mk_ and _site.conf_ in _gluon/site_ directory)
* Opional: Change initial IP address in _gluon/package/gluon-setup-mode/files/lib/gluon/setup-mode/rc.d/S20network_ (default is 192.168.1.1)
* Adjust the git-gluon-repo-path and start the docker container (there is a container start script under _gluon/scripts/container.sh_)
* Change to gluon repo and execute _make update_
* Change to subdirectory _gluon/openwrt_ and execute _make menuconfig_
* Change device model and subtarget
* Change every package and kernel module **which are not needed to mount a USB device** as module (Tab through every settings and subsettings page will take very long and has to be adjusted for every device). WiFi, dnsmasq, lua, etc. can be marked as modules
* Select at least busybox, dropbear, block-mount, kmod-fs-ext4, kmod-uhci/ohci, and all applications necessary to run a minmal OpenWRT to compile inside the image (see https://openwrt.org/docs/guide-user/additional-software/extroot_configuration)
* Select the needed Freifunk packages as modules
* Exit and save configuration
* Execute _make_, this will download, extract, compile and build the image and all selected packages
* The resulting image and packages are located under _gluon/openwrt/bin/targets/_ and the image should be smaller than 4MB. If not, repeat the steps to select and mark applications as modules, compile again.
* Leave the docker container
* Plug the formatted ext4 USB device into the router
* Select the image and flash the router (this can differ for every device), the network cable has to be plugged in a LAN port
* The system should power up and login is possible
* Copy _preinstall.sh_ to router and execute the script (same as https://openwrt.org/docs/guide-user/additional-software/extroot_configuration#configuring_extroot and https://openwrt.org/docs/guide-user/additional-software/extroot_configuration#transferring_data)
* Reboot the router
* The system is powered up and the USB device is used as main drive
* Change to package directory on your PC and start the web server or copy all packages to a web server directory
* Login to your router
* Adjust opkg URLs on the router to download the compiled packages from the local web server
* Execute _opkg update_
* Remove unnecessary packages (see site configs)
* Install needed packages beforehand (WiFi modules, dnsmasq, iw, iwinfo) by executing _opkg install_. Installing all packages in one take can lead to configuration errors.
* Install all needed Freifunk packages (see site config too), e.g. gluon-core ip6tables-zz-legacy gluon-ebtables-limit-arp gluon-web-wifi-config gluon-config-mode-geo-location-osm gluon-config-mode-mesh-vpn gluon-mesh-vpn-tunneldigger gluon-ebtables-source-filter hostapd-mini gluon-status-page gluon-config-mode-geo-location gluon-ebtables-filter-multicast gluon-web-autoupdater gluon-status-page-mesh-batman-adv gluon-web-network gluon-web-private-wifi gluon-radvd gluon-config-mode-hostname gluon-respondd gluon-radv-filterd gluon-ebtables-filter-ra-dhcp gluon-mesh-batman-adv-15 gluon-config-mode-autoupdater gluon-autoupdater gluon-config-mode-outdoor gluon-config-mode-contact-info gluon-web-admin respondd-module-airtime
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
* The local web server is needed due to the installation of the additional packages. It is possible to copy the packages directly to the USB device and install it from there (change opkg URL to something like: _file:///packages/_ )
* The whole process could be simplified if the configuration is supported inside the Gluon Framework.
* Cloning Gluon and then the Freifunk site should match, otherwise you encounter some build or configuration errors, if the site config does not support an actual gluon framework
* The router can be very slow and will not handle many WiFi clients, especially if the router has low flash and memory (4MB/32MB)
