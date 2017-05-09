#!/usr/local/bin/python2.7

from utils import update_or_add_settings

def update_transmission(conf_filename, write_file=False):
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

if __name__ == "__main__":
    update_transmission('/etc/rc.conf', True)
