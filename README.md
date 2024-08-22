# NAC-Jack
Shark Jack payloads for testing exposed RJ45 (ethernet) ports and dealing with port security.

- get-subnet.sh ⇒ plug Shark Jack in and save subnet with timestamp to file  
Idea: Walk around or have someone else walk around and plug into different ports to figure out which networks are reachable from where (network segmentation).

- get-mac.sh ⇒ get MAC address of device (plug into device)  
Idea: NAC whitelists based on device MAC address. Plug into a legit device (eg. phone) and grab its MAC address so you can spoof it.
- spoof-mac.sh ⇒ spoof MAC address of device (plug into network)  
Idea: Add to other scripts to change Shark Jack's MAC address and get around port security.

- scan.sh ⇒ basic nmap scans  
- hunt-subnet-c2.sh ⇒ look for critical subnet, and if found, change colour and connect to cloud C2  
Idea: You want access to a network that isn't the "guest" network. Walk around or have someone else walk around and plug into different ports. When a "non-guest" network is observed, the colour will be different. Leave the Shark Jack there and remote into it via SSH over Hak5 Cloud C2 for further testing.
