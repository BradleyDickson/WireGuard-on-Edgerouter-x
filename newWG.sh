##!/bin/vbash

if [ -z ${1+x} ] ; then echo "configure file is unset"; else

if [ -z ${2+x} ] ; then echo "source IP is unset"; else    


source=`echo $2`
name=`echo wg0`
echo $1 > LastCon
echo $2 > LastSo
add=`grep Address $1 |sed -e 's/,/ /g' |awk '{print $3}'`
pub=`grep Pub $1 |awk '{print $3}'`
pri=`grep Pri $1 |awk '{print $3}'`
end=`grep Endp $1 |awk '{print $3}'`
out=`echo $add |sed -e 's/\// /g' |awk '{print $1}'`

cmd=/opt/vyatta/bin/vyatta-op-cmd-wrapper
cfg=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$cfg begin
$cfg set interfaces wireguard $name address $add
$cfg set interfaces wireguard $name listen-port 51820
$cfg set interfaces wireguard $name route-allowed-ips false
$cfg set interfaces wireguard $name peer $pub endpoint $end
$cfg set interfaces wireguard $name peer $pub allowed-ips 0.0.0.0/0
$cfg set interfaces wireguard $name private-key $pri

$cfg commit
$cfg set service nat rule 5000 description 'wireguard'
$cfg set service nat rule 5000 log disable
$cfg set service nat rule 5000 outbound-interface $name
$cfg set service nat rule 5000 outside-address address $out
$cfg set service nat rule 5000 source address $source
$cfg set service nat rule 5000 type source
$cfg commit
$cfg set protocols static table 1 interface-route 0.0.0.0/0 next-hop-interface $name
$cfg set firewall modify SOURCE_ROUTE rule 10 description 'to WG'
$cfg set firewall modify SOURCE_ROUTE rule 10 source address $source
$cfg set firewall modify SOURCE_ROUTE rule 10 modify table 1
$cfg set interfaces switch switch0 firewall in modify SOURCE_ROUTE
$cfg set service dns forwarding name-server 193.138.218.74

$cfg commit
$cfg save 
$cfg end
fi
fi
