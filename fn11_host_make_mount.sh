#!/bin/sh
#
# Make the setup directory in the jail and create a mount binding to it
JAIL_PATH=/mnt/vol1/iocage/jails/$1/root
JAIL_SETUP_DIR=$JAIL_PATH/root/fn11_setup
if [ ! -d $JAIL_SETUP_DIR ]; then
    mkdir $JAIL_SETUP_DIR
    echo "Made $JAIL_SETUP_DIR"
fi
MOUNTED=`mount`
if echo $MOUNTED | grep $JAIL_SETUP_DIR
  then
    echo "Already mounted"
  else
    mount_nullfs $PWD/$2 $JAIL_SETUP_DIR
    echo "Mounted $JAIL_SETUP_DIR"
fi