##!/bin/vbash

if [ -z ${1+x} ] ; then echo "configure file is unset"; else

name=`echo wg0`
source=`cat LastSo`
conff=`cat LastCon`
add=`grep Address $conff |sed -e 's/,/ /g' |awk '{print $3}'`
pub=`grep Pub $conff |awk '{print $3}'`
pri=`grep Pri $conff |awk '{print $3}'`
end=`grep Endp $conff |awk '{print $3}'`
out=`echo $add |sed -e 's/\// /g' |awk '{print $1}'`

cmd=/opt/vyatta/bin/vyatta-op-cmd-wrapper
cfg=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$cfg begin
$cfg delete interfaces wireguard $name private-key $pri
$cfg delete interfaces wireguard $name peer $pub allowed-ips 0.0.0.0/0
$cfg delete interfaces wireguard $name peer $pub endpoint $end
$cfg delete interfaces wireguard $name listen-port 51820
$cfg delete interfaces wireguard $name address $add
oout=`echo $out`
echo $1 > LastCon

add=`grep Address $1 |sed -e 's/,/ /g' |awk '{print $3}'`
pub=`grep Pub $1 |awk '{print $3}'`
pri=`grep Pri $1 |awk '{print $3}'`
end=`grep Endp $1 |awk '{print $3}'`
out=`echo $add |sed -e 's/\// /g' |awk '{print $1}'`

$cfg set interfaces wireguard $name address $add
$cfg set interfaces wireguard $name listen-port 51820
$cfg set interfaces wireguard $name route-allowed-ips false
$cfg set interfaces wireguard $name peer $pub endpoint $end
$cfg set interfaces wireguard $name peer $pub allowed-ips 0.0.0.0/0
$cfg set interfaces wireguard $name private-key $pri
$cfg commit
$cfg delete service nat rule 5000 outside-address address $oout
$cfg set service nat rule 5000 outside-address address $out
$cfg commit
$cfg save 
$cfg end

fi
