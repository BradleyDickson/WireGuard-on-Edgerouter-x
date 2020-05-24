#!/bin/vbash

#you must supply a wg0.conf config file on the command line to this script
if [ -z ${1+x} ] ; then 
	echo "configure file is unset"
	echo "$0 wg.conf [-test]"
	exit 1
fi
	
name=wg0 #the wireguard device name
add=`grep Address $1 |sed -e 's/,/ /g' |awk '{print $3}'`  #the assigned IP address from your provider
pub=`grep Pub $1 |awk '{print $3}'` #Providers Public Key
pri=`grep Pri $1 |awk '{print $3}'` #Your private Key
end=`grep Endp $1 |awk '{print $3}'` #providers IP and port
out=`echo $add |sed -e 's/\// /g' |awk '{print $1}'` 
firewallModify=balance #the modify firewall rule set used by load balancer
networkGroup=wgClients   # the network group of devices to route over wireguard

if [ "$2" = "-test" ] ; then
	cfg="echo TEST: /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper"
else
	cfg="/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper"
fi

$cfg begin
$cfg set interfaces wireguard $name address $add
$cfg set interfaces wireguard $name listen-port 51820
$cfg set interfaces wireguard $name route-allowed-ips false
$cfg set interfaces wireguard $name peer $pub endpoint $end
$cfg set interfaces wireguard $name peer $pub allowed-ips 0.0.0.0/0
$cfg set interfaces wireguard $name private-key $pri

$cfg commit
$cfg set service nat rule 5004 description 'wireguard'
$cfg set service nat rule 5004 log disable
$cfg set service nat rule 5004 outbound-interface $name
$cfg set service nat rule 5004 outside-address address $out
##$cfg set service nat rule 5004 source address $source
$cfg set service nat rule 5004 source group address-group $networkGroup
$cfg set service nat rule 5004 type source
$cfg commit

$cfg set protocols static table 41 interface-route 0.0.0.0/0 next-hop-interface $name
$cfg set firewall modify $firewallModify rule 41 description 'to WG'
#$cfg set firewall modify $firewallModify rule 41 source address $source
$cfg set firewall modify $firewallModify rule 41 source group address-group wgClients
$cfg set firewall modify $firewallModify rule 41 modify table 41

#this should already be set if you have load balancing enabled
#$cfg set interfaces switch switch0 firewall in modify $firewallModify
#$cfg set service dns forwarding name-server 8.8.8.8

$cfg commit  #enable the changes to the running config
#$cfg save  #save the config to last across reboots 
$cfg end

