rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -Uvh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
# from CentOS / RHEL repos
sudo yum -y install gstreamer gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-bad-free gstreamer-plugins-bad gstreamer-plugins-ugly gstreamer-ffmpeg ffmpeg ffmpeg-devel libquicktime libquicktime-devel
