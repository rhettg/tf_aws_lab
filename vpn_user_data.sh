#!/bin/bash

set -e

echo "Setting hostname"

echo "vpn0" > /etc/hostname
hostname -F /etc/hostname

echo "Configuring Network"
cat <<"EOF" >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF

sysctl -p

iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o eth0 -m policy --dir out --pol ipsec -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o eth0 -j MASQUERADE

echo "Installing StrongSwan"

DEBIAN_FRONTEND=noninteractive apt-get install -y \
    strongswan \
    strongswan-plugin-xauth-generic \
    iptables-persistent

cat <<"EOF" > /etc/ipsec.conf
config setup
   cachecrls=yes
   uniqueids=never
conn cisco
    keyexchange=ikev1
    leftsubnet=10.0.0.0/16
    xauth=server
    leftfirewall=yes
    leftauth=psk
    right=%any
    rightauth=psk
    rightauth2=xauth
    rightsourceip=10.0.250.0/24
    rightdns=10.0.0.2
    auto=add

EOF

cat <<"EOF" > /etc/strongswan.conf
charon {
  dns1 = 10.0.0.2
  cisco_unity = yes
  load_modular = yes
  plugins {
    include strongswan.d/charon/*.conf
    attr {
      # INTERNAL_IP4_DNS
      dns = 10.0.0.2
      # UNITY_DEF_DOMAIN
      28674 = rhettg-lab
      # UNITY_SPLIT_INCLUDE / split-include
      split-include = 10.0.0.0/16
    }
  }
}
include strongswan.d/*.conf

EOF

cat <<"EOF" > /etc/ipsec.secrets

: PSK "ABIGSECRET"
github : XAUTH "password"

EOF

ipsec rereadall
service strongswan restart

echo "user_data Done"
