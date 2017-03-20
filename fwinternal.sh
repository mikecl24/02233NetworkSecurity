#!/bin/bash
#
# a02_fwinternal.sh - Script to setup the firewall in the fwboundary computer
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

# User lookups from User Network dealt with Internal DNS 
iptables -A FORWARD -p UDP -d $intdns --dport 53 -s $usernet -j ACCEPT
iptables -A FORWARD -p UDP -s $intdns --sport 53 -d $usernet -j ACCEPT

# consider UDP states

# Redirect HTTP queries from the User Network to the Internal HTTP Proxy
iptables -A FORWARD -p TCP -s $usernet -d $intproxy --dport 8080 -j ACCEPT
iptables -A FORWARD -p TCP -d $usernet -s $intproxy --sport 8080 -j ACCEPT

# consider TCP states

# Accept POP over SSL for user fron User Network 
iptables -A FORWARD -p TCP -s $usernet -d $intadmin 
  --dport 995 -j ACCEPT
iptables -A FORWARD -p TCP -s $usernet -d $intadmin 
  --dport 110 -j ACCEPT
iptables -A FORWARD -p TCP -d $usernet -s $intadmin 
  --dport 995 -j ACCEPT
iptables -A FORWARD -p TCP -d $usernet -s $intadmin 
  --dport 110 -j ACCEPT

# Use Internal Admin as a proxy for mail for User Network
iptables -A FORWARD -p TCP -s $usernet -d $intadmin --match multiport --dports 25,587 -j ACCEPT
iptables -A FORWARD -p TCP -s $intadmin -d $usernet --match multiport --dports 25,587 -j ACCEPT

# Accept SSH login to Cluser
iptables -A FORWARD -p TCP -s $usernet --dport 22 -d $fwcluster_eth0 -j ACCEPT
iptables -A FORWARD -p TCP -d $usernet --sport 22 -s $fwcluster_eth0 -j ACCEPT 
