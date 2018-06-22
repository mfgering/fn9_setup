#!/usr/bin/env bash
# NOTE: This should be run in the sabnzbd jail where sabnzbd is already installed
#       Update the version variable according

function join_by { local IFS="$1"; shift; echo "$*"; }

function max_version {
    local versions=("$@")
    max_version=( 0 0 0 )
    for version in $versions
    do
        #echo version:$version
        v_parts=(${version//./ })
        for i in  0 1 2
        do
            if [ ${max_version[$i]} -lt ${v_parts[$i]} ]; then
                max_version=("${v_parts[@]}")
                #echo New max version: ${max_version[@]}
                break
            fi
        done
    done
    mv=`join_by . "${max_version[@]}"`
    echo $mv
}

v2=`git ls-remote --symref https://github.com/sabnzbd/sabnzbd | grep '/[0-9]\.[0-9]\{1,\}\.[0-9]\{1,\}$' | cut -f2 | cut -d'/' -f3`
versions=`join_by ' ' $v2`
ver=`max_version "${versions[@]}"`
echo This version is $ver
service sabnzbd stop
echo Downloading and installing version $ver
mkdir /tmp/fn11_setup
rm -fr /tmp/fn11_setup/SABnzbd /tmp/fn11_setup/sabnzbd /usr/local/share/sabnzbd
cd /tmp/fn11_setup; fetch https://github.com/sabnzbd/sabnzbd/releases/download/$ver/SABnzbd-$ver-src.tar.gz; \
 tar xzf SABnzbd-$ver-src.tar.gz; \
 mv SABnzbd-$ver sabnzbd; \
 sed -i '' -e "s/#!\/usr\/bin\/python -OO/#!\/usr\/local\/bin\/python2.7 -OO/" sabnzbd/SABnzbd.py; \
 mv sabnzbd /usr/local/share/
rm -fr /tmp/fn11_setup
service sabnzbd start
echo Done
