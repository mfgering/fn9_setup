#!/bin/sh
#
# Make the setup directory in the jail and create a mount binding to it
JAIL_PATH=`jls -j $1 path`
JAIL_SETUP_DIR=$JAIL_PATH/root/fn9_setup
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