#!/bin/sh

echo "installing pisyde"

python2.7 get-pip.py
pip2.7 install wheel
cd PySide-1.2.2
pip2.7 install dist/PySide-1.2.2-cp27-none-linux_x86_64.whl
python2.7 pyside_postinstall.py -install
cd ..
pip2.7 install numpy
pip2.7 install Pillow
cp npShotgunIntegration.so /usr/lib64/mozilla/plugins

echo "done installing pisyde"
echo " "

echo "installing cgkit 2.0"

sudo yum -y install scons
cd cgkit-2.0.0/supportlib
scons
cd ..
python setup.py install

echo "done installing cgkit"
echo " "