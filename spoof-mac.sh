#!/bin/bash
# credit to https://forums.hak5.org/topic/50879-how-to-use-macchanger-utility/

# MAC address to spoof
MAC_ADDRESS="7c:dd:90:f3:9f:5d"

SERIAL_WRITE "[*] Setting up payload"
LED SETUP
NETMODE DHCP_CLIENT
ifconfig eth0 down
ifconfig eth0 hw ether $MAC_ADDRESS
ifconfig eth0 up

SERIAL_WRITE "[*] Waiting for IP from DHCP"
LED R SOLID
while ! ifconfig eth0 | grep "inet addr"; do sleep 1; done
SUBNET=$(ip addr | grep -i eth0 | grep -i inet | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}[\/]{1}[0-9]{1,2}")
IP=${SUBNET%%/*}
SERIAL_WRITE "[*] Obtained IP $SUBNET"

# change this
#SERIAL_WRITE "[*] Attacking"
#LED ATTACK

SERIAL_WRITE "[*] Finished"
LED FINISH