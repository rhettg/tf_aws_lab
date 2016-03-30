#!/bin/bash

set -e

echo "Setting hostname"

echo "vpn0" > /etc/hostname
hostname -F /etc/hostname

echo "Installing StrongSwan"

apt-get install -y strongswan strongswan-plugin-xauth-generic

cat <<"EOF" > /etc/ipsec.conf
config setup
   cachecrls=yes
   uniqueids=never
conn cisco
    keyexchange=ikev1
    leftsubnet=10.0.1.0/16
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
      28674 = stage-us-west-2
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

service strongswan restart

echo "user_data Done"
