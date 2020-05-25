# WireGuard-on-Edgerouter-x with Dual WAN 

When using the Dual Wan (or multiple WAN) configuration with the edgerouter, the standard scripts needed to modified to handle the case where the modify balance group already exists, as well as existing nat masquarade rules.

This script will route all traffic for addressGroup "wgClients" over wg0. any addresses not in wgClients will be routed normally. You should define wgClients beforehand, either via command line or the gui.

assuming you have a working wg0.conf style config (saved as wg0.conf in this example) file from your provider and that wgClients address group is defined, you can turn on the VPN using the following:

```./startVPN.sh wg0.conf```

and stop with the following:

```./stopVPN.sh wg0.conf```
