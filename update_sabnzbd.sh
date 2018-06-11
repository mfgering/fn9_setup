#!/usr/bin/env bash
# NOTE: This should be run in the sabnzbd jail where sabnzbd is already installed
#       Update the version variable according
ver=2.3.4
service sabnzbd stop
echo Downloading and installing version $ver
mkdir /tmp/fn9_setup
rm -fr /tmp/fn9_setup/SABnzbd /tmp/fn9_setup/sabnzbd /usr/local/share/sabnzbd
cd /tmp/fn9_setup; fetch https://github.com/sabnzbd/sabnzbd/releases/download/$ver/SABnzbd-$ver-src.tar.gz; \
 tar xzf SABnzbd-$ver-src.tar.gz; \
 mv SABnzbd-$ver sabnzbd; \
 sed -i '' -e "s/#!\/usr\/bin\/python -OO/#!\/usr\/local\/bin\/python2.7 -OO/" sabnzbd/SABnzbd.py; \
 mv sabnzbd /usr/local/share/
rm -fr /tmp/fn9_setup
service sabnzbd start
echo Done
