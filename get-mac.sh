#!/bin/bash

LOOT_DIR=/root/loot
# file to write MAC address to
MAC_FILE=$LOOT_DIR/mac_address.txt

SERIAL_WRITE "[*] Setting up payload"
LED SETUP
NETMODE DHCP_SERVER

SERIAL_WRITE "[*] Waiting for target to connect"
LED ATTACK
while ! arp -a | grep 172; do sleep 1; done

SERIAL_WRITE "[*] Obtained MAC address"
arp -a > $MAC_FILE

SERIAL_WRITE "[*] Wrote MAC address to file"
LED FINISH