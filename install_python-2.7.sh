#!/bin/sh

echo "installing python 2.7"

cd /mnt/FrimaTI/CentOS_FX_WS
yum -y install cmake
yum -y install libXp libXp-devel zlib zlib-devel libxml2 libxml2-devel bzip2-devel openssl-devel libpcap-devel ncurses-devel readline-devel tk-devel xz-devel
cd Python-2.7.8
make install
cd ..
cp local_files/python.sh /etc/profile.d
echo "done installing python 2.7"
echo " "
echo "Need reboot... rebooting in 10sec"
sleep 10
reboot
