#!/usr/local/bin/python2.7
import sys

from utils import update_or_add_settings

def _add_transmission(conf_filename, write_file=False):
    settings = [
        ('transmission_enable', '"YES"'),
        ('transmission_conf_dir', '"/config"'),
        ('transmission_download_dir', '"/downloads"'),
        ('transmission_watch_dir', '"/watched"'),
        ('transmission_user', '"media"'),
    ]
    with open(conf_filename) as f:
        contents = f.read()
    contents = update_or_add_settings(contents, settings)
    if write_file:
        with open(conf_filename, 'w') as f:
            f.write(contents)
    return contents

######
# Commands
######

def add_transmission_rc_conf(*args):
    _add_transmission('/etc/rc.conf', True)

def test(args):
    return 42

if __name__ == '__main__':

    if len(sys.argv) > 1:
        f_name = sys.argv[1]
        fn_args = sys.argv[2:]
        result = getattr(sys.modules[__name__], f_name)(fn_args)
    else:
        print("No function argument.")