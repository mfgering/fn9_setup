#!/bin/sh
#
# $FreeBSD: head/news/sabnzbdplus/files/sabnzbd.in 410708 2016-03-09 16:59:18Z feld $
#
# PROVIDE: sabnzbd
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf.local or /etc/rc.conf
# to enable this service:
#
# sabnzbd_enable (bool):        Set to NO by default.
#                       Set it to YES to enable it.
# sabnzbd_conf_dir:     Directory where sabnzbd configuration
#                       data is stored.
#                       Default: /usr/pbi/sabnzbd-amd64/sabnzbd
# sabnzbd_user:         The user account sabnzbd daemon runs as what
#                       you want it to be. It uses '_sabnzbd' user by
#                       default. Do not sets it as empty or it will run
#                       as root.
# sabnzbd_group:        The group account sabnzbd daemon runs as what
#                       you want it to be. It uses '_sabnzbd' group by
#                       default. Do not sets it as empty or it will run
#                       as wheel.
# sabnzbd_pidfile:      Set the location of the sabnzbd pidfile

. /etc/rc.subr

name=sabnzbd
rcvar=sabnzbd_enable
load_rc_config ${name}

: ${sabnzbd_enable:=NO}
: ${sabnzbd_user:=_sabnzbd}
: ${sabnzbd_group:=_sabnzbd}
: ${sabnzbd_conf_dir="/config"}
: ${sabnzbd_pidfile:="/var/run/sabnzbd/sabnzbd.pid"}

pidfile=${sabnzbd_pidfile}

start_precmd="${name}_prestart"
command_interpreter="/usr/local/bin/python2.7"
command="/usr/local/share/sabnzbd/SABnzbd.py"
command_args="-s 0.0.0.0 --daemon -f ${sabnzbd_conf_dir}/sabnzbd.ini --pidfile ${pidfile}"

sabnzbd_prestart()
{
	#PATH=${PATH}:/usr/pbi/sabnzbd-amd64/bin:/usr/pbi/sabnzbd-amd64/sbin
	export LC_CTYPE="en_US.UTF-8"
	for sabdir in ${sabnzbd_conf_dir} ${pidfile%/*}; do
		if [ ! -d "${sabdir}" ]; then
			install -d -o ${sabnzbd_user} -g ${sabnzbd_group} ${sabdir}
		fi
	done
}

run_rc_command "$1"
