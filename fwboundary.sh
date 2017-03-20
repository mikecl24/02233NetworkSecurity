#!/bin/bash
#
# a02_fwboundary.sh - Script to setup the firewall in the fwboundary computer
#
# Made by:
# Mike Castro Lundin -s162901
# Juan Manuel Donaire Felipe - s150662 
# Sébastien Pierre Christophe Gondron - s162339
# Aleksandrs Levi - s162870

# Delete all existing rules
iptables -F

# DROP everything not covered by the policies
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP

# Variables
fwboundary_eth0="192.168.0.2"
fwboundary_eth1="10.47.74.254"
fwcluster_eth0="10.47.74.252"
fwcluster_eth1="192.168.37.254"
fwmain_eth0="10.47.74.253"
fwmain_eth1="192.168.47.254"
fwinternal_eth0="192.168.47.253"
fwinternal_eth1="192.168.75.254"
extdns="10.47.74.53"
extmail="10.47.74.25"
extweb="10.47.74.80"
intadmin="192.168.47.99"
intdns="192.168.47.53"
intproxy="192.168.47.80"
clusnode="192.168.37.100"
usernode="192.168.74.100"
usernet="192.168.74.0/23"
extdmz="10.47.74.0/24"
intdmz="192.168.74.0/24"
cluster="192.168.37.0/24"

# User lookups from the internet
iptables -t nat -A PREROUTING -p UDP --dport 53 -j DNAT --to $extdns:53
iptables -A FORWARD -p UDP -d $extdns --dport 53 -j ACCEPT
iptables -A FORWARD -p UDP -s $extdns --dport 53 -j ACCEPT

# Consider UDP states

# Whitelist the trusted servers for DNS Zone Transfer
iptables -N CHK-WHITELIST
#iptables -A CHK-WHITELIST -s example.net -j ACCEPT
iptables -A CHK-WHITELIST -s 192.168.0.1 -j ACCEPT

# Accept Zone Transfer to External DNS Server only from trusted servers
iptables -t nat -A PREROUTING -p TCP --dport 53 -j DNAT --to $extdns:53
iptables -A FORWARD -p TCP -d $extdns --dport 53 -j CHK-WHITELIST
iptables -A FORWARD -p TCP -s $extdns --sport 53 -j CHK-WHITELIST

# Accept HTTP queries from Internet to the External Web Sever
iptables -t nat -A PREROUTING -p TCP --dport 80 -j DNAT --to $extweb:80
iptables -A FORWARD -p TCP -d $extweb --dport 80 -j ACCEPT
iptables -A FORWARD -p TCP -s $extweb --sport 80 -j ACCEPT
#maybe consider tcp states

# Redirect HTTP queries from the User Network to the Internal HTTP Proxy
iptables -A FORWARD -p TCP -s $intproxy --dport 80 -j ACCEPT
iptables -A FORWARD -p TCP -d $intproxy --sport 80 -j ACCEPT

# consider tcp states

# Accept SMTP queries from Internet
iptables -t nat -A PREROUTING -p TCP --dport 587 -j DNAT --to $extmail:587
iptables -t nat -A PREROUTING -p TCP --dport 25 -j DNAT --to $extmail:25
iptables -A FORWARD -p TCP -d $extmail --dport 25 -j ACCEPT
iptables -A FORWARD -p TCP -d $extmail --dport 587 -j ACCEPT
iptables -A FORWARD -p TCP -s $extmail --sport 25 -j ACCEPT
iptables -A FORWARD -p TCP -s $extmail --sport 587 -j ACCEPT

# Use Internal Admin as a proxy for mail for User Network
iptables -A FORWARD -p TCP -s $intadmin --match multiport --dport 25,587 -j ACCEPT
iptables -A FORWARD -p TCP -d $intadmin --match multiport --dport 25,587 -j ACCEPT

# Accept SSH login to Cluser
iptables -t nat -A PREROUTING -p TCP --dport 22 -j DNAT --to $fwcluster_eth0:22
iptables -A FORWARD -p TCP --dport 22 -d $fwcluster_eth0 -j ACCEPT
iptables -A FORWARD -p TCP --sport 22 -s $fwcluster_eth0 -j ACCEPT

# Accept mail from the cluster
iptables -A FORWARD -p TCP -s $cluster --match multiport --dports 25,587 -j ACCEPT
iptables -A FORWARD -p TCP -d $cluster --match multiport --sports 25,587 -j ACCEPT
