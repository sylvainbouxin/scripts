#!/bin/sh

#INSTALL_ROOT="/mnt/cifs-fx-nas-03/Archive/sbouxin"
INSTALL_ROOT="/fx-nas-03/fx-prod/Archive/sbouxin"

# CREATE_MOUNT_AND_LINKS=

# INSTALL_NVIDIA_DRIVERS=

INSTALL_MONO=
MONO_VERSION="2.10.9"

INSTALL_DEADLINE=
DEADLINE_VERSION="6.2.0.32"

INSTALL_MAYA=
MAYA_VERSION="2014"

INSTALL_DELIGHT=true
DELIGHT_VERSION="11.0.134"

INSTALL_NUKE=
NUKE_VERSION="8.0v6"

INSTALL_HOUDINI=
HOUDINI_VERSION="13.0.498"

# INSTALL_RV=

INSTALL_CODECS=

# INSTALL_RVLINK=

REBOOT=

# if test $CREATE_MOUNT_AND_LINKS; then
# echo "creating and mounting the various network resources..."
# mkdir /mnt/deadlineRepo
# mkdir -p /mnt/transfert
# chmod -R 777 /mnt/transfert
# mkdir -p /mnt/Z
# chmod -R 777 /mnt/Z
# sed -i '$ a\\\\\Frimashare\\usager\\nseif /mnt/Z cifs credentials=/root/creds,noperm 0 0' /etc/fstab
# sed -i '$ a\\\\\fs-nas-00\\transfert /mnt/transfert cifs credentials=/root/creds,noperm 0 0' /etc/fstab
# sed -i '$ a\\\\\fsdeadline01\\deadline /mnt/deadlineRepo cifs credentials=/root/creds,noperm 0 0' /etc/fstab
# mount -a
# echo "done creating and mounting the various network resources..."
# echo " "
# fi

if test $INSTALL_NVIDIA_DRIVERS; then
echo "installing NVIDIA Drivers ..."
# yum -y groupinstall "Development Tools"
# yum -y install kernel-devel kernel-headers dkms
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
./DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run --mode unattended --repositorydir /mnt/deadlineRepo --licenseserver @prodflexmr --launcherdaemon true --daemonuser renderfx --monoexec /usr/bin/mono 
cd $INSTALL_ROOT
cp local_files/deadlineclient.sh /etc/profile.d/
sed -i '4s/.*/# chkconfig: - 99 80/' /etc/init.d/deadline6launcherservice
mv /etc/rc2.d/S20deadline6launcherservice /etc/rc2.d/S99deadline6launcherservice
mv /etc/rc3.d/S20deadline6launcherservice /etc/rc3.d/S99deadline6launcherservice
mv /etc/rc5.d/S20deadline6launcherservice /etc/rc5.d/S99deadline6launcherservice
perl -pi.bak -e 's/RestartStalledSlave=true/RestartStalledSlave=false/g' /var/lib/Thinkbox/Deadline6/deadline.ini
echo "done installing Deadline version $DEADLINE_VERSION ..."
echo " "
fi

if test $INSTALL_MAYA; then
echo "installing Maya version $MAYA_VERSION ..."
cd $INSTALL_ROOT
# yum -y install libXp libXp-devel
cd Autodesk-Maya-$MAYA_VERSION
rpm -ivh adlmapps7-7.0.51-0.x86_64.rpm adlmflexnetclient-7.0.51-0.x86_64.rpm Composite_2014-2014.0-862715.x86_64.rpm MatchMover2014_0_64-2014.0-450.x86_64.rpm Maya2014_64-2014.0-986.x86_64.rpm mentalrayForMaya2014_0-2014.0-418.x86_64.rpm
cd $INSTALL_ROOT
rm -rf /usr/autodesk/maya$MAYA_VERSION-x64/bin/License.env
cp local_files/License.env /usr/autodesk/maya$MAYA_VERSION-x64/bin/
cp local_files/maya.lic /var/flexlm/
export LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R7/lib64/
/usr/autodesk/maya$MAYA_VERSION-x64/bin/adlmreg -i N 657F1 657F1 2014.0.0.F 393-77433081 /var/opt/Autodesk/Adlm/Maya$MAYA_VERSION/MayaConfig.pit
cd $INSTALL_ROOT
cp local_files/maya.sh /etc/profile.d/
# cp local_files/ffx.sh /etc/profile.d/
echo "done installing Maya version $MAYA_VERSION ..."
echo " "
fi

if test $INSTALL_DELIGHT; then
echo "installing 3delight version $DELIGHT_VERSION ..."
cd $INSTALL_ROOT/3delight-$DELIGHT_VERSION
./install --prefix /opt
cd /opt/3delight-$DELIGHT_VERSION
unset DELIGHT
cd $INSTALL_ROOT
cp local_files/3delight.sh /etc/profile.d/
rm -rf /opt/3delight-$DELIGHT_VERSION/Linux-x86_64/rendermn.ini
cp local_files/rendermn.ini /opt/3delight-$DELIGHT_VERSION/Linux-x86_64/
ln -s /opt/3delight-$DELIGHT_VERSION/Linux-x86_64/lib/lib3delight.so /usr/autodesk/maya$MAYA_VERSION-x64/lib/
echo "done installing 3delight version $DELIGHT_VERSION ..."
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
cd $INSTALL_ROOT/houdini-$HOUDINI_VERSION
./houdini.install --no-license --make-dir /opt/hfs$HOUDINI_VERSION --accept-EULA
cp $INSTALL_ROOT/local_files/houdini.sh /etc/profile.d/
mkdir /opt/hfs$HOUDINI_VERSION/houdini/scripts/deadline
cp /mnt/deadlineRepo/submission/Houdini/Client/DeadlineHoudiniClient.py /opt/hfs$HOUDINI_VERSION/houdini/scripts/deadline/
cp /mnt/deadlineRepo/submission/Houdini/Client/MainMenuCommon.xml /opt/hfs$HOUDINI_VERSION/houdini/
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
cd $INSTALL_ROOT
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -Uvh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
# from CentOS / RHEL repos
yum -y install gstreamer gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-bad-free gstreamer-plugins-bad gstreamer-plugins-ugly gstreamer-ffmpeg ffmpeg ffmpeg-devel libquicktime libquicktime-devel
echo "done installing codecs ..."
fi

if test $INSTALL_RVLINK; then
echo "installing rvlink ..."
gconftool-2 -s /desktop/gnome/url-handlers/rvlink/command '/opt/rv-Linux-x86-64-4.0.11/bin/rv %s' --type String
gconftool-2 -s /desktop/gnome/url-handlers/rvlink/enabled --type Boolean true
cp local_files/shotgun_fields_config_custom.mu ~/.rv/Mu
echo "done installing rvlink ..."
fi

if test $REBOOT; then
echo "rebooting now... "
reboot
fi

if test $INSTALL_HOUDINI; then
echo " "
echo "* Manual installation remaining for Houdini. Run this :"
echo " "
echo "cd /opt/hfs$HOUDINI_VERSION && source houdini_setup"
#echo "hkey"
#echo "hserver -S poste-0058.frima.local"
echo " "
fi