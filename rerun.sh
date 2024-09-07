#!/bin/bash

# main script code

# This code was taken from bash scripts in /usr/bin on Shark Jack
SERIAL_WRITE "[*] Waiting for Ethernet link to go down..."
until swconfig dev switch0 port 0 get link | grep -q 'link:down'; do
  sleep 1
done

SERIAL_WRITE "[*] Ethernet disconnected"
stop_ssh

LED SETUP
echo "execute_payload" | at now