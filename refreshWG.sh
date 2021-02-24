#!/bin/vbash

if [ -z ${1+x} ] ; then echo "configure file is unset"; else


name=`echo wg0`
add=`grep Address $1 |sed -e 's/,/ /g' |awk '{print $3}'`
pub=`grep Pub $1 |awk '{print $3}'`
pri=`grep Pri $1 |awk '{print $3}'`
end=`grep Endp $1 |awk '{print $3}'`
prt=`echo $end | sed -e 's/:/ /g' |awk '{print $2}'`
out=`echo $add |sed -e 's/\// /g' |awk '{print $1}'`

cmd=/opt/vyatta/bin/vyatta-op-cmd-wrapper
cfg=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$cfg begin
$cfg delete interfaces wireguard $name 
$cfg delete service nat rule 5000
$cfg commit

$cfg set interfaces wireguard $name address $add
$cfg set interfaces wireguard $name listen-port $prt
$cfg set interfaces wireguard $name route-allowed-ips false
$cfg set interfaces wireguard $name peer $pub endpoint $end
$cfg set interfaces wireguard $name peer $pub allowed-ips 0.0.0.0/0
$cfg set interfaces wireguard $name private-key $pri

$cfg commit
$cfg set service nat rule 5000 description 'wireguard'
$cfg set service nat rule 5000 log disable
$cfg set service nat rule 5000 outbound-interface $name
$cfg set service nat rule 5000 outside-address address $out
##$cfg set service nat rule 5000 source address $source
$cfg set service nat rule 5000 source group address-group wgClients
$cfg set service nat rule 5000 type source
$cfg commit
$cfg save 
$cfg end
fi
