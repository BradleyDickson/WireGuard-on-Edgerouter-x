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

$cfg delete interfaces wireguard 
$cfg delete service nat rule 5004 
$cfg delete protocols static table 41 
$cfg delete firewall modify $firewallModify rule 41

$cfg commit  #commit the current changes to the running config
#$cfg save #save the changes to the config.boot to last across reboots
$cfg end

