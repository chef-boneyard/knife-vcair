#!/bin/sh
# Cargo culted from https://github.com/opscode/opscode-omnitruck/blob/master/views/install.sh.erb

if test -f "/etc/lsb-release" && grep -q DISTRIB_ID /etc/lsb-release; then
  platform=`grep DISTRIB_ID /etc/lsb-release | cut -d "=" -f 2 | tr '[A-Z]' '[a-z]'`
  platform_version=`grep DISTRIB_RELEASE /etc/lsb-release | cut -d "=" -f 2`
elif test -f "/etc/debian_version"; then
  platform="debian"
  platform_version=`cat /etc/debian_version`
elif test -f "/etc/redhat-release"; then
  platform=`sed 's/^\(.\+\) release.*/\1/' /etc/redhat-release | tr '[A-Z]' '[a-z]'`
  platform_version=`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release`
fi

if test "$platform" = "ubuntu"; then
        sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
        sed -i 's/dns.*/dns-nameservers 8.8.8.8 8.8.4.4/g' /etc/network/interfaces
fi

if test "$platform" = "centos"; then
	printf "nameserver 8.8.8.8\nnameserver 8.8.4.4" >> /etc/resolv.conf
fi
