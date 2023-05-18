#!/bin/sh

passwd root

DEVICE="/dev/sda1"
eval $(block info ${DEVICE} | grep -o -e "UUID=\S*")
uci -q delete fstab.overlay
uci set fstab.overlay="mount"
uci set fstab.overlay.uuid="${UUID}"
uci set fstab.overlay.target="/overlay"
uci commit fstab

mount ${DEVICE} /mnt
tar -C /overlay -cvf - . | tar -C /mnt -xf -

#reboot
