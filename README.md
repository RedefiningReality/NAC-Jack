# NAC-Jack
Shark Jack payloads for testing exposed RJ45 (ethernet) ports and dealing with port security.

## Fixing colour issues in Shark Jack cable
Full credit to [this forum post](https://forums.hak5.org/topic/58286-shark-jack-cable-led-bug/)  
Change the following lines at the bottom of `/usr/bin/LED`:
```
if pgrep -f LED | grep -qvE "$$|${PPID}"; then                                  
    #kill "$(pgrep -f LED | grep -vE "$$|${PPID}" | tr '\n' ' ')" > /dev/null 2>
    ps | grep LED | grep -v grep | awk '{print $1}' | grep -v $$ | xargs kill -9
fi                                                                              
if pgrep -f DO_A_BARREL_ROLL | grep -qvE "$$|${PPID}"; then                     
    #kill "$(pgrep -f DO_A_BARREL_ROLL | grep -vE "$$|${PPID}" | tr '\n' ' ')" >
    ps | grep LED | grep -v grep | awk '{print $1}' | grep -v $$ | xargs kill -9
fi
```

### rerun.sh
*add to the end of other scripts to rerun payload on network change without rebooting Shark Jack*

Idea: Once a payload is run, it needs to be manually rerun or the Shark Jack needs to be rebooted to run it again. The Shark Jack takes a while to boot.
These lines at the end of a script cause the Shark Jack to wait until it's plugged into a new port then automatically rerun the payload.

### get-subnet.sh
*plug Shark Jack in and save subnet to file*

Idea: Walk around or have someone else walk around and plug into different ports to figure out which networks are reachable from where (network segmentation).
#### Variables
- `LOOT_DIR` → directory to store output files
- `SUBNETS_FILE` → file to store list of subnets (IP/CIDR)
- `PUBLIC_TEST_URL` → URL to test web connectivity
#### Output Files
- append: `$SUBNETS_FILE` → contains `<ip>/<cidr>` for each network the Shark Jack was plugged into
- create: `$LOOT_DIR/<ip>-<cidr>.txt` → contains the output of `ip a` (network information)
#### Colours
- Magenta ⇒ waiting for network - if you plug it in and it stays magenta for 5+ seconds, the port is probably dead
- Red ⇒ waiting to obtain IP from DHCP - if you plug it in and it stays red for 5+ seconds, either DHCP is not being served or there's port security in place
- Flashing yellow ⇒ saving subnet information to file (optional)
- Flashing blue ⇒ connecting to cloud C2 and exfiltrating files
- Green ⇒ finished

### get-mac.sh
*get MAC address of device (plug into device)*

Idea: NAC whitelists based on device MAC address. Plug into a legit device (eg. phone) and grab its MAC address so you can spoof it. Alternatively, consider using Packet Squirrel with NETMODE CLONE.
#### Variables
- `MAC_FILE` → file to write MAC address to
#### Output Files
- `$MAC_FILE` → contains the output of `arp -a`, which includes the connected device's MAC address
#### Colours
- Magenta ⇒ waiting for network - if you plug it in and it stays magenta for 5+ seconds, the port is probably dead
- Flashing yellow ⇒ retrieving MAC address
- Green ⇒ finished
### spoof-mac.sh
*spoof MAC address of device (plug into network)*

Idea: Add to other scripts to change Shark Jack's MAC address and get around port security.
#### Variables
- `MAC_ADDRESS` → MAC address to spoof
#### Colours
- Magenta ⇒ waiting for network - if you plug it in and it stays magenta for 5+ seconds, the port is probably dead
- Red ⇒ waiting to obtain IP from DHCP - if you plug it in and it stays red for 5+ seconds, either DHCP is not being served or you provided the wrong MAC
- Green ⇒ finished

### scan.sh
*basic nmap scans*
#### Variables
- `LOOT_DIR` → directory to store scan results
- `<scan type>_SCAN` → nmap scan flags
#### Output Files
- `$LOOT_DIR/<ip>-<scan type>.nmap`
- `$LOOT_DIR/<ip>-<scan type>.gnmap`
- `$LOOT_DIR/<ip>-<scan type>.xml`
#### Colours
- Magenta ⇒ waiting for network - if you plug it in and it stays magenta for 5+ seconds, the port is probably dead
- Red ⇒ waiting to obtain IP from DHCP - if you plug it in and it stays red for 5+ seconds, either DHCP is not being served or there's port security in place
- Flashing yellow ⇒ scanning
- Flashing blue ⇒ uploading scan results to cloud C2 (optional)
- Green ⇒ finished

### hunt-subnet-c2.sh
*look for critical subnet, and if found, change colour and connect to cloud C2*

Idea: You want access to a network that isn't the "guest" network. Walk around or have someone else walk around and plug into different ports. When a "non-guest" network is observed, the colour will be different (white). Leave the Shark Jack there and remote into it via SSH over Hak5 Cloud C2 for further testing.
#### Variables
- `IP_MATCH` → IP regex that indicates access to critical subnet
- `SAVE_SUBNETS` → (true/false) save IP/CIDR obtained to file and exfil to cloud C2
- `LOOT_DIR` (optional) → directory to store output files
- `SUBNETS_FILE` (optional) → file to store list of subnets (IP/CIDR)
- `PUBLIC_TEST_URL` → URL to test web connectivity
#### Output Files (optional)
- append: `$LOOT_DIR/subnets.txt` → contains `<ip>/<cidr>` for each network the Shark Jack was plugged into
- create: `$LOOT_DIR/<ip>-<cidr>.txt` → contains the output of `ip a` (network information)
#### Colours
- Magenta ⇒ waiting for network - if you plug it in and it stays magenta for 5+ seconds, the port is probably dead
- Red ⇒ waiting to obtain IP from DHCP - if you plug it in and it stays red for 5+ seconds, either DHCP is not being served or there's port security in place
- Flashing yellow ⇒ saving subnet information to file (optional)
- Flashing blue ⇒ connecting to cloud C2 and exfiltrating files
- Green ⇒ finished, subnet is not critical
- White ⇒ finished, critical subnet found - access through SSH or cloud C2
