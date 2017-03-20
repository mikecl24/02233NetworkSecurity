#!/bin/bash
#
# a02_fwboundary.sh - Script to setup the firewall in the fwboundary computer
#
# Made by:
# Mike Castro Lundin -s162901
# Juan Manuel Donaire Felipe - s150662 
# Sébastien Pierre Christophe Gondron - s162339
# Aleksandrs Levi -

# Delete all existing rules
iptables -F

# DROP everything not covered by the policies
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUPUT DROP

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

# User lookups from the cluster dealt with external dns
iptables -A FORWARD -p UDP -d $extdns --dport 53 -s $cluster -j ACCEPT
iptables -A FORWARD -p UDP -s $extdns --sport 53 -d $cluster -j ACCEPT

# consider UDP states

# Accept SSH login to Cluser
iptables -A INPUT -p TCP -s $usernet --dport 22 -j ACCEPT
iptables -A OUTPUT -p TCP -d $usernet --sport 22 -j ACCEP

# Accept mail from the cluster
iptables -A FORWARD -p TCP -s $cluster --match multiport --dports 25,587 -j ACCEPT
iptables -A FORWARD -p TCP -d $cluster --match multiport --sports 25,587 -j ACCEPT

# ACCEPT ping from cluster
iptables -A OUTPUT -p ICMP -s $cluster --match multiport --dports 1,58 -j ACCEPT
iptables -A INPUT -p ICMP -d  $cluster --match multiport --sports 1,58 -j ACCEPT
iptables -A INPUT -p TCP -s $cluster --sport 22 -j ACCEPT
iptables -A OUTPUT -p TCP -d $cluster --dport 22 -j ACCEPT
