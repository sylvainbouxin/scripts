#!/bin/sh

INSTALL_ROOT="root location including all sowftware sources"

CREATE_MOUNT_AND_LINKS="YES"

INSTALL_NVIDIA_DRIVERS="YES"

INSTALL_MONO="YES"
MONO_VERSION="2.10.9"

INSTALL_DEADLINE="YES"
DEADLINE_VERSION="6.2.0.32"

INSTALL_DELIGHT="YES"
DELIGHT_VERSION="11.0.83"

INSTALL_MAYA="YES"
MAYA_VERSION="2014"

INSTALL_NUKE="YES"
NUKE_VERSION="8.0v3"

INSTALL_HOUDINI="YES"
HOUDINI_VERSION="13.0.498"

INSTALL_RV="YES"

INSTALL_CODECS="YES"

REBOOT="YES"

if test $CREATE_MOUNT_AND_LINKS; then
echo "creating and mounting the various network resources..."
mkdir /mnt/deadlineRepo
sed -i '$ a\\\\\fs-nas\\pool-01\\share /mnt/share cifs credentials=/root/creds,noperm 0 0' /etc/fstab
mount -a
mkdir /mnt/render
ln -s /mnt/share/SHOTGUN/projects /mnt
ln -s /mnt/share/SHOTGUN/software /mnt
echo "done creating and mounting the various network resources..."
echo " "
fi

if test $INSTALL_NVIDIA_DRIVERS; then
echo "installing NVIDIA Drivers ..."
yum -y groupinstall "Development Tools"
yum -y install kernel-devel kernel-headers dkms
sed -i '$ a\blacklist nouveau' /etc/modprobe.d/blacklist.conf
mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
dracut -v /boot/initramfs-$(uname -r).img $(uname -r)
echo "done installing NVIDIA Drivers ..."
fi

if test $INSTALL_MONO; then
echo "installing Mono version $MONO_VERSION ..."
cd $INSTALL_ROOT
cp -r mono-$MONO_VERSION/x86_64/ /tmp/x86_64
cp mono-$MONO_VERSION/thinkbox.repo /etc/yum.repos.d/
yum -y update 
yum -y install mono-complete
echo "done installing Mono version $MONO_VERSION ..."
echo " "
fi

if test $INSTALL_DEADLINE; then
echo "installing Deadline version $DEADLINE_VERSION ..."
cd $INSTALL_ROOT
cd Deadline-$DEADLINE_VERSION
./DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run --mode unattended --repositorydir /mnt/deadlineRepo --licenseserver @prodflexmr --launcherdaemon true --daemonuser renderfx --slavestartup true --restartstalled true --monoexec /usr/bin/mono 
cd $INSTALL_ROOT
cp local_files/deadlineclient.sh /etc/profile.d/
echo "done installing Deadline version $DEADLINE_VERSION ..."
echo " "
fi

if test $INSTALL_MAYA; then
echo "installing Maya version $MAYA_VERSION ..."
cd $INSTALL_ROOT
yum -y install libXp libXp-devel
cd Autodesk-Maya-$MAYA_VERSION
rpm -ivh adlmapps7-7.0.51-0.x86_64.rpm adlmflexnetclient-7.0.51-0.x86_64.rpm Composite_2014-2014.0-862715.x86_64.rpm MatchMover2014_0_64-2014.0-450.x86_64.rpm Maya2014_64-2014.0-986.x86_64.rpm mentalrayForMaya2014_0-2014.0-418.x86_64.rpm
cd $INSTALL_ROOT
rm -rf /usr/autodesk/maya$MAYA_VERSION-x64/bin/License.env
cp local_files/License.env /usr/autodesk/maya$MAYA_VERSION-x64/bin/
cp local_files/maya.lic /var/flexlm/
export LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R7/lib64/
/usr/autodesk/maya$MAYA_VERSION-x64/bin/adlmreg -i N xxxxx xxxxx yyyy.y.y.y zzz-zzzzzzzz /var/opt/Autodesk/Adlm/Maya$MAYA_VERSION/MayaConfig.pit
cd $INSTALL_ROOT
cp local_files/maya.sh /etc/profile.d/
echo "done installing Maya version $MAYA_VERSION ..."
echo " "
fi

if test $INSTALL_NUKE; then
echo "installing Nuke version $NUKE_VERSION ..."
cd $INSTALL_ROOT
mkdir /usr/local/Nuke$NUKE_VERSION
unzip Nuke-$NUKE_VERSION/* -d /usr/local/Nuke$NUKE_VERSION
mkdir /usr/OFX
cd $INSTALL_ROOT
cp -r Libs/6.3/plugins/Ocula /usr/OFX
cp -r Libs/Nuke/Furnace_4.2_Nuke/* /usr/local/Nuke$NUKE_VERSION/plugins/
mkdir -p /usr/local/foundry/FLEXlm
cd $INSTALL_ROOT
cp local_files/foundry_client.lic /usr/local/foundry/FLEXlm
cp local_files/nukePlugins.sh /etc/profile.d/
echo "done installing Nuke version $NUKE_VERSION ..."
echo " "
fi

if test $INSTALL_HOUDINI; then
echo "installing Houdini version $HOUDINI_VERSION ..."
cd $INSTALL_ROOT
cd houdini-$HOUDINI_VERSION
./houdini.install --no-license --make-dir /opt/hfs$HOUDINI_VERSION
cd /opt/hfs$HOUDINI_VERSION
ls
source houdini_setup
hserver -S poste-0058.frima.local
cd $INSTALL_ROOT
cp local_files/houdini.sh /etc/profile.d/
echo "done installing Houdini version $HOUDINI_VERSION ..."
echo " "
fi

if test $INSTALL_RV; then
echo "installing RV ..."
cd $INSTALL_ROOT
tar xzvf rv-Linux-x86-64-4.0.11.tar.gz -C /opt
cp local_files/license.gto /opt/rv-Linux-x86-64-4.0.11/etc
cp local_files/rv.sh /etc/profile.d/
echo "done installing RV ..."
fi

if test $INSTALL_CODECS; then
echo "installing codecs ..."
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -Uvh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
# from CentOS / RHEL repos
sudo yum -y install gstreamer gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-bad-free gstreamer-plugins-bad gstreamer-plugins-ugly gstreamer-ffmpeg ffmpeg ffmpeg-devel libquicktime libquicktime-devel
echo "done installing codecs ..."
fi

if test $REBOOT; then
echo "rebooting now... "
reboot
fi
