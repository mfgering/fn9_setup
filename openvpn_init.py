#!/usr/local/bin/python
# /etc/rc.conf needs these:
#openvpn_enable="YES"
#openvpn_configfile="/openvpn/default.ovpn"
#openvpn_flags="--script-security 2"

from utils import update_or_add_settings

def update_openvpn(conf_filename, write_file=False):
    settings = [
        ('openvpn_enable', '"YES"'),
        ('openvpn_configfile', '"/openvpn/default.ovpn"'),
        ('openvpn_flags', '"--script-security 2"'),
    ]
    with open(conf_filename) as f:
        contents = f.read()
    contents = update_or_add_settings(contents, settings)
    if write_file:
        with open(conf_filename, 'w') as f:
            f.write(contents)
    return contents

if __name__ == "__main__":
    update_openvpn('/etc/rc.conf')
