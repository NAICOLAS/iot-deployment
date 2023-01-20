#!/bin/ash

# Simple installation process for NODA Simple Modbus Server
# https://noda.se

# Install NODA Simple Modbus Server on Teltonika RUT device.
# https://docs.noda.se/modbusgw/packages.html

# Download and add the NODA repository public key file for the package signature check (Important).
# cd /tmp
# wget https://opkg.noda.se/public.key
wget https://opkg.noda.se/public.key -O /tmp/public.key
opkg-key add /tmp/public.key

# Add the NODA repository to allowed repositories.
# cat /etc/opkg/customfeeds.conf # Displays content of customfeeds.conf
# echo -e "src/gz noda https://opkg.noda.se" >> /etc/opkg/customfeeds.conf
NODA_REPO_SOURCE="src/gz noda https://opkg.noda.se"
CUSTOM_SOURCE_FILE="/etc/opkg/customfeeds.conf"
# cat "${CUSTOM_SOURCE_FILE}" | if [ ! $(grep -irsxqF "${NODA_REPO_SOURCE}") ]; then echo -e ${NODA_REPO_SOURCE} >> ${CUSTOM_SOURCE_FILE}; fi
# cat /etc/opkg/customfeeds.conf | if [ ! $(grep -irsxqF "src/gz noda https://opkg.noda.se") ]; then echo -e ${"src/gz noda https://opkg.noda.se"} >> ${"/etc/opkg/customfeeds.conf"}; fi;
cat /etc/opkg/customfeeds.conf | if [ ! $(grep -irsxqF "src/gz noda https://opkg.noda.se") ]; then echo -e ${"src/gz noda https://opkg.noda.se"} >> ${"/etc/opkg/customfeeds.conf"}; fi;

# Update OPKG after public key installation
opkg update

# Disable the internal (original) Teltonika Modbus Slave/Server
uci set modbus.modbus.enabled='0'
uci commit modbus
reload_config

# Install the new Simple Modbus Server from NODA
# simple-modbus-server
opkg install simple-modbus-server -V # Use -V for verbose output

# Enable the new Modbus server (simple-modbus-server)
# uci get modbus_server.modbus.enabled
uci set modbus_server.modbus.enabled='1'
uci commit modbus_server

# Enable service autostart
/etc/init.d/modbus_server enable

# Start the service
/etc/init.d/modbus_server start

# Service status
# /etc/init.d/modbus_server status

# Commit changes
uci commit

# Reloads the configuration (sort of a "soft reboot")
reload_config

# Reboot the device (if wanted/needed)
# reboot
