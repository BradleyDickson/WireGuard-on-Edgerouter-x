# WireGuard-on-Edgerouter-x
These scripts combine things from NordVPN instructions and from various posts by Lochnair to quickly establish a working WireGuard interface on your Edgerouter. The idea is to configure WireGuard and use the policy based routing to direct traffic from a single IP on your network through the tunnel.

To setup WireGuard using mullvad-fakeexample.conf configuration for device IP 192.168.1.32:
````bash
sudo ./newWG.sh mullvad-fakeexample.conf 192.168.1.32
````

To change from current server to a different server:
````bash
sudo ./toggleWG.sh new-configfile.conf
````

The above assumes you installed wireguard on your edgerouter and placed your VPN configureation files, newWG.sh and toggleWG.sh scripts on your router. These scripts will write LastCon and LastSo files. LastCon stores the in-use configuration name and LastSo stores the source IP forwarded to the tunnel. **It is also assumed that you use port 51820 for wireguard. Edit newWG.sh and change the listen-port if this is not the case.**  

Device IP associated with the tunnel can be changed in configure mode using
````bash
set service nat rule 5000 source address NEWIP
set firewall modify SOURCE_ROUTE rule 10 source address NEWIP
````

Outside configure mode you should also update the contents of LastSo, created by NewWG.sh.

The scripts expect configurations in the format used by Mullvad, so a fake Mullvad configuration is included here should you need to build such a file.

**It is possible to use a NAT address group rather than a single source IP by editing newWG.sh. All IP in the group are then routed to wireguard interface. I notice, though, that I sometimes have to reboot the router after running newWG.sh when I use NAT group as the source. So, you may want to reboot if the wg0 interface seems inactive after running newWG.sh.**
