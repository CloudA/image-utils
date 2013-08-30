#!/bin/bash
unset HISTFILE
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
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

echo "--- Update VM ---"
rpm -Uvh http://fedora.mirror.nexicom.net/epel/6/i386/epel-release-6-8.noarch.rpm
yum -y update

CURRENT_KERNEL=$(uname -r)
LATEST_KERNEL=$(rpm -qa kernel | sed 's/kernel-//' | sort -r | tail -n 1)
if [ "$CURRENT_KERNEL" != "$LATEST_KERNEL" ] 
then
	echo "$(pwd)/init.sh" >> /root/.bashrc
	reboot
	exit 0 
fi

unset HISTFILE
echo "--- Disable Grub Timeout ---"
sed -i 's/^timeout=/timeout=0/' /boot/grub/grub.conf

echo "--- Install Cloud Utilities ---"
cd /root/image-utils/centos/
$(pwd)/cloud-init-build.sh
$(pwd)/cloud-growpart.sh

echo "--- Set New Root Password ---"
passwd root

echo "--- Cleanup ---"
find /var/log -type f -exec rm -f {} \;
echo -n "" > /root/.bash_history
rm -Rf /root/install.log* /root/anaconda-ks.cfg

echo "--- VM Now Cloud Ready ---"
exit 0
