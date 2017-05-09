#!/usr/local/bin/python2.7

import re

from subprocess import Popen, PIPE

def get_tun_ip():
    pipe = Popen("ifconfig tun0", shell=True, stdout=PIPE, stderr=PIPE).stdout
    x = pipe.read()
    if len(x) == 0:
        return None
    return x.split("inet ")[1].split(" ")[0]

def stop_transmission():
    pipe = Popen("service transmission stop", shell=True, stdout=PIPE, stderr=PIPE).stdout

def update_transmission_bind_addr(addr, settings_file='/config/settings.json'):
    pattern = r'^(.*bind-address-ipv4"\s*:\s*")(.*?)(".*)$'
    p = re.compile(pattern, re.MULTILINE)
    bind_ip = None
    with open(settings_file) as f:
        contents = f.read()
    m = p.match(contents)
    bind_ip = m.group(2)
    if bind_ip != addr:
        stop_transmission()
        updated_contents = p.sub(r'\1'+addr+r'3', contents)
        with open(settings_file, 'w') as f:
            f.write(contents)

def run():
    tun_ip = get_tun_ip()
    if tun_ip is None:
        stop_transmission()
    else:
        # Check that the tunnel IP matches the transmission config
        pass
    print(tun_ip)

if __name__ == "__main__":
    run()
