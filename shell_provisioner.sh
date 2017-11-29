#!/bin/bash

set -e

OSTYPE="unknown"

if [ -x /usr/bin/lsb_release ]; then
  OSTYPE=$(lsb_release -i -s)
  CODENAME=$(lsb_release -sc)
elif [ -e /etc/redhat-release ]; then
  OSTYPE="RedHat"
else
  echo "Unsupported OS!" >&2
  exit 1
fi

if [ ! -e /var/initial_update ]; then
    echo "Running initial upgrade"
    if [ "$OSTYPE" = "Debian" ] || [ "$OSTYPE" = "Ubuntu" ]; then
        apt-get update
        apt-get dist-upgrade -y
        date > /var/initial_update
    elif [ "$OSTYPE" = "RedHat" ]; then
# Disable initial update to prevent the kernel update bug
# https://bugs.centos.org/view.php?id=13453
# https://bugzilla.redhat.com/show_bug.cgi?id=1463241
#
#        yum update -y
        date > /var/initial_update
    fi
fi

if [ "$OSTYPE" = "RedHat" ]; then
    if [ `getenforce` = 'Enforcing' ]; then
        echo "Setting selinux to permissive"
        setenforce 0
    fi

    if grep -qP "^SELINUX=enforcing" /etc/selinux/config; then
        echo "Disabling selinux after reboot"
        sed -i 's/^\\(SELINUX=\\)enforcing/\\1disabled/' /etc/selinux/config
    fi
fi
