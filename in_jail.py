#!/usr/local/bin/python2.7
import sys

from utils import edit_rc_conf_settings

#TODO: use sysrc to edit the files

def edit_rc_conf(conf_filename, settings, write_file, add_conf):
    with open(conf_filename) as f:
        contents = f.read()
    contents = edit_rc_conf_settings(contents, settings, add_conf)
    if write_file:
        with open(conf_filename, 'w') as f:
            f.write(contents)
    return contents

def edit_transvpnmon_rc_conf(conf_filename, write_file=False, add_conf=True):
    settings = [
        ('transvpnmon_enable', '"YES"'),
    ]
    return edit_rc_conf(conf_filename, settings, write_file, add_conf)

def edit_sonarr_rc_conf(conf_filename, write_file=False, add_conf=True):
    settings = [
        ('sonarr_enable', '"YES"'),
        ('sonarr_user', '"media"'),
        ('sonarr_data_dir', '"/sonarr/config"'),
    ]
    return edit_rc_conf(conf_filename, settings, write_file, add_conf)

def edit_radarr_rc_conf(conf_filename, write_file=False, add_conf=True):
    settings = [
        ('radarr_enable', '"YES"'),
        ('radarr_user', '"media"'),
        ('radarr_data_dir', '"/radarr/config"'),
    ]
    return edit_rc_conf(conf_filename, settings, write_file, add_conf)

def edit_openvpn_rc_conf(conf_filename, write_file=False, add_conf=True):
    settings = [
        ('openvpn_enable', '"YES"'),
        ('openvpn_configfile', '"/openvpn/default.ovpn"'),
        ('openvpn_flags', '"--script-security 2"'),
    ]
    return edit_rc_conf(conf_filename, settings, write_file, add_conf)

def edit_transmission_rc_conf(conf_filename, write_file=False, add_conf=True):
    settings = [
        ('transmission_enable', '"YES"'),
        ('transmission_conf_dir', '"/transmission/config"'),
        ('transmission_download_dir', '"/transmission/downloads"'),
        ('transmission_watch_dir', '"/transmission/watched"'),
        ('transmission_user', '"media"'),
    ]
    return edit_rc_conf(conf_filename, settings, write_file, add_conf)

def edit_sabnzbd_rc_conf(conf_filename, write_file=False, add_conf=True):
    settings = [
        ('sabnzbd_enable', '"YES"'),
        ('sabnzbd_conf_dir', '"/sabnzbd/config"'),
        ('sabnzbd_user', '"media"'),
        ('sabnzbd_group', '"media"'),
    ]
    return edit_rc_conf(conf_filename, settings, write_file, add_conf)

def edit_jackett_rc_conf(conf_filename, write_file=False, add_conf=True):
    settings = [
        ('jackett_enable', '"YES"'),
        ('jackett_data_dir', '"/jackett/config"'),
        ('jackett_user', '"media"'),
    ]
    return edit_rc_conf(conf_filename, settings, write_file, add_conf)

######
# Commands
######

def cmd_add_jackett_rc_conf(*args):
    edit_jackett_rc_conf('/etc/rc.conf', write_file=True)

def cmd_add_transvpnmon_rc_conf(*args):
    edit_transvpnmon_rc_conf('/etc/rc.conf', write_file=True)

def cmd_add_radarr_rc_conf(*args):
    edit_radarr_rc_conf('/etc/rc.conf', write_file=True)

def cmd_add_sonarr_rc_conf(*args):
    edit_sonarr_rc_conf('/etc/rc.conf', write_file=True)

def cmd_add_openvpn_rc_conf(*args):
    edit_openvpn_rc_conf('/etc/rc.conf', write_file=True)

def cmd_add_transmission_rc_conf(*args):
    edit_transmission_rc_conf('/etc/rc.conf', write_file=True)

def cmd_add_sabnzbd_rc_conf(*args):
    edit_sabnzbd_rc_conf('/etc/rc.conf', write_file=True)

def cmd_remove_openvpn_rc_conf(*args):
    edit_openvpn_rc_conf('/etc/rc.conf', write_file=True, add_conf=False)

def cmd_remove_transmission_rc_conf(*args):
    edit_transmission_rc_conf('/etc/rc.conf', write_file=True, add_conf=False)

def cmd_remove_sabnzbd_rc_conf(*args):
    edit_sabnzbd_rc_conf('/etc/rc.conf', write_file=True, add_conf=False)

def cmd_test(args):
    return 42

if __name__ == '__main__':

    commands = ['test', 'add_openvpn_rc_conf', 'add_transmission_rc_conf',
                'add_sabnzbd_rc_conf', 'remove_openvpn_rc_conf',
                'remove_transmission_rc_conf', 'remove_sabnzbd_rc_conf',
                'add_transvpnmon_rc_conf', 'add_sonarr_rc_conf', 'add_radarr_rc_conf',
                'add_jackett_rc_conf',]
    if len(sys.argv) > 1:
        cmd_name = sys.argv[1]
        if cmd_name not in commands:
            raise ValueError("Command '%s' does not exist." % cmd_name)
        fn_args = sys.argv[2:]
        result = getattr(sys.modules[__name__], "cmd_"+cmd_name)(fn_args)
        print(result)
    else:
        raise ValueError("Missing command")
