#!/usr/local/bin/python2.7
import sys

from utils import edit_rc_conf_settings

def _edit_rc_conf(conf_filename, settings, write_file, add_conf):
    with open(conf_filename) as f:
        contents = f.read()
    contents = edit_rc_conf_settings(contents, settings, add_conf)
    if write_file:
        with open(conf_filename, 'w') as f:
            f.write(contents)
    return contents

def _edit_openvpn_rc_conf(conf_filename, write_file=False, add_conf=True):
    settings = [
        ('openvpn_enable', '"YES"'),
        ('openvpn_configfile', '"/openvpn/default.ovpn"'),
        ('openvpn_flags', '"--script-security 2"'),
    ]
    return _edit_rc_conf(conf_filename, settings, write_file, add_conf)

def _edit_transmission_rc_conf(conf_filename, write_file=False):
    settings = [
        ('transmission_enable', '"YES"'),
        ('transmission_conf_dir', '"/config"'),
        ('transmission_download_dir', '"/downloads"'),
        ('transmission_watch_dir', '"/watched"'),
        ('transmission_user', '"media"'),
    ]
    return _edit_rc_conf(conf_filename, settings, write_file, add_conf)

######
# Commands
######

def add_openvpn_rc_conf(*args):
    _edit_openvpn_rc_conf('/etc/rc.conf', write_file=True)

def add_transmission_rc_conf(*args):
    _edit_transmission_rc_conf('/etc/rc.conf', write_file=True)

def remove_openvpn_rc_conf(*args):
    _edit_openvpn_rc_conf('/etc/rc.conf', write_file=True, add_conf=False)

def remove_transmission_rc_conf(*args):
    _edit_transmission_rc_conf('/etc/rc.conf', write_file=True, add_conf=False)


def test(args):
    return 42

if __name__ == '__main__':

    if len(sys.argv) > 1:
        f_name = sys.argv[1]
        fn_args = sys.argv[2:]
        result = getattr(sys.modules[__name__], f_name)(fn_args)
    else:
        print("No function argument.")