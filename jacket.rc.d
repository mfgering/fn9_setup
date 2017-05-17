#!/bin/sh
#
# $FreeBSD$
#

# PROVIDE: jackett
# REQUIRE: LOGIN
# KEYWORD: shutdown

# Add the following lines to /etc/rc.conf to enable jackett:
# jackett_enable="YES"

. /etc/rc.subr

name="jackett"
rcvar=jackett_enable

load_rc_config $name

: ${jackett_enable="NO"}
: ${jackett_user:="jackett"}
: ${jackett_data_dir:="/var/db/jackett"}

procname="/usr/local/bin/mono"
command="/usr/sbin/daemon"
command_args="-f ${procname} /usr/local/share/Jackett/JackettConsole.exe -d ${jackett_data_dir}"

start_precmd=jackett_precmd

jackett_precmd()
{
        export XDG_CONFIG_HOME=${jackett_data_dir}

        if [ ! -d ${jackett_data_dir} ]; then
                install -d -o ${jackett_user} ${jackett_data_dir}
        fi
}

run_rc_command "$1"