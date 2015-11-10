#!/bin/sh
#
# Debian 7 (Wheezy) does not have the newer libnss3 version (>=3.15) that Libreswan requires.
# The following workaround is required BEFORE running my VPN auto install script (vpnsetup.sh).
#
# Copyright (C) 2015 Lin Song
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

if [ "$(sed 's/\..*//' /etc/debian_version 2>/dev/null)" != "7" ]; then
  echo "Looks like you aren't running this script on Debian 7 (Wheezy)."
  exit
fi

if [ "$(id -u)" != 0 ]; then
  echo "Sorry, you need to run this script as root."
  exit
fi

if [ "$(uname -m)" = "x86_64" ]; then
  my_arch=amd64
elif [ "$(uname -m)" = "i686" ]; then
  my_arch=i386
else
  echo "Sorry, your OS architecture is not supported."
  exit
fi

# Update package index and install wget
apt-get -y update
apt-get -y install wget

# Install newer packages from the "MX and MEPIS Community Repository" (http://main.mepis-deb.org/).
# Reference: http://forums.debian.net/viewtopic.php?t=118013
cd /var/tmp
base_url=http://main.mepis-deb.org/mepiscr/testrepo/pool/test/n

FILE1=libnspr4_4.10.7-1mcr120+1_$my_arch.deb
FILE2=libnspr4-dev_4.10.7-1mcr120+1_$my_arch.deb
FILE3=libnss3_3.17-1mcr120+1_$my_arch.deb
FILE4=libnss3-dev_3.17-1mcr120+1_$my_arch.deb
FILE5=libnss3-tools_3.17-1mcr120+1_$my_arch.deb

wget -t 3 -T 30 -nv -O $FILE1 $base_url/nspr/$FILE1
wget -t 3 -T 30 -nv -O $FILE2 $base_url/nspr/$FILE2
wget -t 3 -T 30 -nv -O $FILE3 $base_url/nss/$FILE3
wget -t 3 -T 30 -nv -O $FILE4 $base_url/nss/$FILE4
wget -t 3 -T 30 -nv -O $FILE5 $base_url/nss/$FILE5

if [ -f $FILE1 ] && [ -f $FILE2 ] && [ -f $FILE3 ] && [ -f $FILE4 ] && [ -f $FILE5 ]; then
  dpkg -i $FILE1 $FILE2 $FILE3 $FILE4 $FILE5 && rm -f $FILE1 $FILE2 $FILE3 $FILE4 $FILE5
  apt-get install -f
  echo " "
  echo 'Completed! If no error occurred in the output above, you may now proceed to run vpnsetup.sh.'
else
  echo " "
  echo 'Could not retrieve libnspr4/libnss3 package(s) from the MX/MEPIS repository. Aborting.'
  exit
fi
