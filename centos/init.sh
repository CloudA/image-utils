#!/bin/bash

echo "--- Clean bashrc ---"
sed -i 's/.*init.sh//' /root/.bashrc

echo "--- Installing basic packages ---"
yum -y install wget openssh-clients vim

echo ""
echo "--- Configuring Network ---"
echo 'DEVICE="eth0"' > /etc/sysconfig/network-scripts/ifcfg-eth0
echo 'BOOTPROTO="dhcp"' >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo 'NM_CONTROLLED="no"' >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo 'ONBOOT="yes"' >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo 'TYPE="Ethernet"' >> /etc/sysconfig/network-scripts/ifcfg-eth0
rm -f /etc/udev/rules.d/70-persistent-net.rules
ln -s /dev/null /etc/udev/rules.d/70-persistent-net.rules
echo ""

echo "--- Disable SELinux ---"
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

echo "--- Update VM ---"
rpm -Uvh http://fedora.mirror.nexicom.net/epel/6/i386/epel-release-6-8.noarch.rpm
yum -y update

CURRENT_KERNEL=$(uname -r)
LATEST_KERNEL=$(rpm -qa kernel | sed 's/kernel-//' | tail -n 1)
if [ "$CURRENT_KERNEL" != "$LATEST_KERNEL" ] 
then
	echo "$(pwd)/init.sh" >> /root/.bashrc
	reboot
	exit 0 
fi

echo "--- Install Cloud Utilities ---"
$(pwd)/cloud-init-build.sh
$(pwd)/cloud-growpart.sh

echo -n "" > /root/.bash_history

echo "--- VM Now Cloud Ready ---"
exit 0
