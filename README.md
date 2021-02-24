# WireGuard-on-Edgerouter-x
These scripts combine things from NordVPN instructions and from various posts by Lochnair to quickly establish a working WireGuard interface on your Edgerouter. The idea is to configure WireGuard and use the policy based routing to direct traffic from a single IP on your network through the tunnel.

## WireGuard for single or multiple IPs

Where IP1 IP2, etc, are your local IP addresses and mullvad.conf is your wireguard conf file:
````bash
sudo ./fullsetWG.sh IP1 IP2 mullvad.conf
````
This will work for how ever many IP addresses you route through your WG interface. The WG intergace is named wg0 and the IP are blocked in a NAT group called wgClients.

Change WG configurations with
````bash
./refreshWG.sh mullvad.conf
````
where mullvad.conf is a new conf file.


## Single IP scripts

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

