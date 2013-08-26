#!/bin/bash

cd /tmp

echo 'Installing dependencies...'
yum -y install git euca2ools qemu-img

echo 'Getting centos-image-resize and cloud-utils...'
git clone https://github.com/flegmatik/centos-image-resize.git
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/cloud-utils-0.27-5.el6.noarch.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/cloud-utils-growpart-0.27-5.el6.noarch.rpm
wget http://pkgs.repoforge.org/qemu/qemu-img-0.15.0-1.el6.rfx.i686.rpm
echo 'Done.'

echo 'Installing cloud-utils...'
rpm -Uvh cloud-utils*.rpm
rpm -Uvh qemu-img*.rpm
echo 'Done.'

echo 'Modify init...'
sed -i '/cp \/boot\/grub\/grub.conf/i chmod +x ${install_dir}/init-part' centos-image-resize/centos-image-mod.sh
cd centos-image-resize/
./centos-image-mod.sh
echo 'Done.'

echo 'Remove udev net rules...'
rm -f /etc/udev/rules.d/70-persistent-net.rules
ln -s /dev/null /etc/udev/rules.d/70-persistent-net.rules
echo 'Done.'
