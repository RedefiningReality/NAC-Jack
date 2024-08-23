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
add to the end of other scripts to rerun payload on network change without rebooting Shark Jack  
Idea: Once a payload is run, it needs to be manually rerun or the Shark Jack needs to be rebooted to run it again. The Shark Jack takes a while to boot.
These lines at the end of a script cause the Shark Jack to wait until it's plugged into a new port then automatically rerun the payload.

### get-subnet.sh
plug Shark Jack in and save subnet with timestamp to file  
Idea: Walk around or have someone else walk around and plug into different ports to figure out which networks are reachable from where (network segmentation).

### get-mac.sh
get MAC address of device (plug into device)  
Idea: NAC whitelists based on device MAC address. Plug into a legit device (eg. phone) and grab its MAC address so you can spoof it. Alternatively, consider using Packet Squirrel with NETMODE CLONE.
### spoof-mac.sh ⇒ spoof MAC address of device (plug into network)  
Idea: Add to other scripts to change Shark Jack's MAC address and get around port security.

### scan.sh
basic nmap scans
#### Colours
- Magenta ⇒ waiting for network - if you plug it in and it stays magenta for 5+ seconds, the port is probably dead
- Red ⇒ waiting to obtain IP from DHCP - if you plug it in and it stays red for 5+ seconds, either DHCP is not being served or there's port security in place
- Flashing yellow ⇒ scanning
- Flashing blue ⇒ uploading scan results to cloud C2 (optional)
- Green ⇒ finished

### hunt-subnet-c2.sh ⇒ look for critical subnet, and if found, change colour and connect to cloud C2  
Idea: You want access to a network that isn't the "guest" network. Walk around or have someone else walk around and plug into different ports. When a "non-guest" network is observed, the colour will be different. Leave the Shark Jack there and remote into it via SSH over Hak5 Cloud C2 for further testing.
#### Colours
- Magenta ⇒ waiting for network - if you plug it in and it stays magenta for 5+ seconds, the port is probably dead
- Red ⇒ waiting to obtain IP from DHCP - if you plug it in and it stays red for 5+ seconds, either DHCP is not being served or there's port security in place
- Flashing yellow ⇒ saving subnet information to file (optional)
- Flashing blue ⇒ critical subnet found, connecting to cloud C2
- Green ⇒ finished, subnet is not critical
- White ⇒ finished, critical subnet found - access through cloud C2
