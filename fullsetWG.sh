#!/bin/vbash

narg=`echo $@ |wc|awk '{print $2}'`
if [ $narg -lt 2 ] ; then 
echo 'You are missing arguments.
run as: FullWG.sh IP1 IP2 mulvad.conf
for any number of ip address.
'

else
declare -a arg
arg=( `echo $@`)
name=`echo wg0`
add=`grep Address ${arg[$((narg-1))]} |sed -e 's/,/ /g' |awk '{print $3}'`
pub=`grep Pub ${arg[$((narg-1))]} |awk '{print $3}'`
pri=`grep Pri ${arg[$((narg-1))]} |awk '{print $3}'`
end=`grep Endp ${arg[$((narg-1))]} |awk '{print $3}'`
out=`echo $add |sed -e 's/\// /g' |awk '{print $1}'`
ispre=`grep -i Preshar ${arg[$((narg-1))]} |wc |awk '{print $2}'`
if [ $ispre -gt 0 ] ; then
pre=`grep -i Preshar ${arg[$((narg-1))]} |awk '{print $3}'`
fi
echo $add
echo $pub                                
echo $pri                                  
echo $end 
prt=`echo $end | sed -e 's/:/ /g' |awk '{print $2}'`
echo $out  

declare -a arg
arg=( `echo $@`)
cmd=/opt/vyatta/bin/vyatta-op-cmd-wrapper
cfg=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$cfg begin
$cfg set firewall group address-group wgClients
for ((i=0;i<$((narg-1));i++)) ; do
$cfg set firewall group address-group wgClients address ${arg[$i]}
done
$cfg commit
$cfg save 
$cfg end

echo ' sleeping 15 to settle wgClients...'
sleep 15
echo 'moving on'

cmd=/opt/vyatta/bin/vyatta-op-cmd-wrapper                                 
cfg=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$cfg begin
$cfg set interfaces wireguard $name address $add
$cfg set interfaces wireguard $name listen-port $prt
$cfg set interfaces wireguard $name route-allowed-ips false
$cfg set interfaces wireguard $name peer $pub endpoint $end
$cfg set interfaces wireguard $name peer $pub allowed-ips 0.0.0.0/0
$cfg set interfaces wireguard $name private-key $pri
if [ $ispre -gt 0 ] ; then
    $cfg set interfaces wireguard $name peer $pub preshared-key $pre
fi
$cfg commit
$cfg set service nat rule 5000 description 'wireguard'
$cfg set service nat rule 5000 log disable
$cfg set service nat rule 5000 outbound-interface $name
$cfg set service nat rule 5000 outside-address address $out
$cfg set service nat rule 5000 source group address-group wgClients
$cfg set service nat rule 5000 type source
$cfg commit
$cfg set protocols static table 1 interface-route 0.0.0.0/0 next-hop-interface $name
$cfg set firewall modify SOURCE_ROUTE rule 10 description 'to WG'
$cfg set firewall modify SOURCE_ROUTE rule 10 source group address-group wgClients
$cfg set firewall modify SOURCE_ROUTE rule 10 modify table 1
$cfg set interfaces switch switch0 firewall in modify SOURCE_ROUTE
$cfg set service dns forwarding name-server 8.8.8.8

$cfg commit
$cfg save 
$cfg end

fi
