#!/bin/sh

echo "installing cgkit 2.0"

cd /mnt/FrimaTI/CentOS_FX_WS
sudo yum -y install scons
cd cgkit-2.0.0/supportlib
scons
cd ..
python setup.py install

echo "done installing cgkit"
echo " "