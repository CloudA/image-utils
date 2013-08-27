#!/bin/bash

cd /tmp

echo 'Installing dependencies...'
yum -y install git euca2ools qemu-img

echo 'Getting centos-image-resize and cloud-utils...'
git clone https://github.com/CloudA/centos-image-resize.git 
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/cloud-utils-0.27-5.el6.noarch.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/cloud-utils-growpart-0.27-5.el6.noarch.rpm
if [ "$(uname -m)" == "i686" ]
	wget http://pkgs.repoforge.org/qemu/qemu-img-0.15.0-1.el6.rfx.i686.rpm
fi
echo 'Done.'

echo 'Installing cloud-utils...'
rpm -Uvh cloud-utils*.rpm
if [ "$(uname -m)" == "i686" ]
	rpm -Uvh qemu-img*.rpm
fi
echo 'Done.'

echo 'Modify init...'
#No longer needed since commit 764d656a63390a707afa045e952eda2b97cb96da
#sed -i '/cp \/boot\/grub\/grub.conf/i chmod +x ${install_dir}/init-part' centos-image-resize/centos-image-mod.sh
cd centos-image-resize/
chmod +x centos-image-mod.sh
chmod +x init-part
./centos-image-mod.sh
echo 'Done.'
