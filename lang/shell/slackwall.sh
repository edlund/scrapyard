#!/bin/bash

ROOTUID=0
ENOTROOT=67

if [ $UID -ne $ROOTUID ] ; then
  echo "try again as root"
  exit $ENOTROOT
fi

modprobe ip_conntrack
modprobe ip_conntrack_ftp

iptables --flush
iptables -t nat --flush
iptables -t mangle --flush

iptables --policy INPUT DROP
iptables --policy OUTPUT ACCEPT

iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -p tcp -i eth0 --dport 22 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp -i eth0 --dport 80 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp -i eth0 --dport 25 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp -i eth0 --dport 21 -m state --state NEW -j ACCEPT

iptables -A INPUT -p icmp -j ACCEPT

iptables -A INPUT -d 255.255.255.255/0.0.0.255 -j DROP
iptables -A INPUT -d 224.0.0.1 -j DROP

iptables -A INPUT -j REJECT

