#!/bin/bash

# Load the configfs kernel module for dynamic device tree overlays
insmod /opt/lib/modules/of_configfs.ko

# Apply the device tree overlay
mount -t configfs none /sys/kernel/config
mkdir -p /sys/kernel/config/device-tree/overlays/no-cc1352-driver
cat /opt/lib/dtb/k3-am625-beagleplay-bcfserial-no-firmware.dtbo > /sys/kernel/config/device-tree/overlays/no-cc1352-driver/dtbo
cat /sys/kernel/config/device-tree/overlays/no-cc1352-driver/status # applied

# Verify the overlay applied and reload the platform serial driver
cat /proc/device-tree/bus@f0000/serial@2860000/mcu/status # disabled
echo 2860000.serial > /sys/devices/platform/bus@f0000/2860000.serial/driver/unbind
echo 2860000.serial > /sys/devices/platform/bus@f0000/2800000.serial/driver/bind

sleep infinity
