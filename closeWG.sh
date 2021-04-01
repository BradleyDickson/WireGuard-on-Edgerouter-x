#!/bin/vbash

name=`echo wg0`
cmd=/opt/vyatta/bin/vyatta-op-cmd-wrapper
cfg=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
$cfg begin
$cfg delete interfaces wireguard $name 
$cfg delete service nat rule 5000
$cfg delete protocols static table 1
$cfg delete firewall modify SOURCE_ROUTE rule 10 
$cfg delete firewall group address-group wgClients
$cfg delete service dns forwarding name-server 

$cfg commit
$cfg save 
$cfg end

