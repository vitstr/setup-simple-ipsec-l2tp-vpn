#!/bin/bash
#
# Auto IP Update Script for DigitalOcean or Other Servers
#
# For detailed instructions, please see:
# https://blog.ls20.com/bash-script-for-automatic-ip-updates-on-amazon-ec2-or-digitalocean/
#
# Copyright (C) 2013 Lin Song
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see http://www.gnu.org/licenses/.

PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
IP_REGEX="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"

[ ! -f /root/IPADDR ] && { echo "IPADDR file does not exist! Aborting."; exit 1; }
. /root/IPADDR

[[ ! "${OLD_PUBLIC_IP}" =~ ${IP_REGEX} ]] && { echo "OLD PUBLIC IP NOT FOUND OR INVALID! Aborting."; exit 1; }
[[ ! "${PUBLIC_IP}" =~ ${IP_REGEX} ]] && { echo "PUBLIC IP NOT FOUND OR INVALID! Aborting."; exit 1; }

# FOR OPENSWAN/STRONGSWAN/LIBRESWAN VPN USERS:
FL1="/etc/ipsec.conf"; FL2="/etc/ipsec.secrets"
 
if [ "$OLD_PUBLIC_IP" != "$PUBLIC_IP" ]; then
  # FOR OPENSWAN/STRONGSWAN/LIBRESWAN VPN USERS:
  sed -i "s/${OLD_PUBLIC_IP}/${PUBLIC_IP}/" $FL1
  sed -i "s/${OLD_PUBLIC_IP}/${PUBLIC_IP}/" $FL2
fi

echo "OLD_PUBLIC_IP=${PUBLIC_IP}" > /root/IPADDR

# FOR OPENSWAN/STRONGSWAN/LIBRESWAN VPN USERS:
/sbin/service ipsec-assist restart
