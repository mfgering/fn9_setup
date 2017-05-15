#!/usr/local/bin/python2.7

import re
import time

from subprocess import Popen, PIPE

DEBUG = False

def get_tun_ip():
    pipe = Popen("ifconfig tun0", shell=True, stdout=PIPE, stderr=PIPE).stdout
    x = pipe.read()
    if len(x) == 0:
        return None
    return x.split("inet ")[1].split(" ")[0]

def status_transmission():
    """Return True if running, False if not."""
    p = Popen("service transmission status", shell=True, stdout=PIPE, stderr=PIPE)
    (so, se) = p.communicate()
    return True if p.returncode == 0 else False

def start_transmission():
    if DEBUG:
        print("Starting transmission")
    p = Popen("service transmission start", shell=True, stdout=PIPE, stderr=PIPE)
    (so, se) = p.communicate()
    return p.returncode

def stop_transmission():
    if DEBUG:
        print("Stopping transmission")
    p = Popen("service transmission stop", shell=True, stdout=PIPE, stderr=PIPE)
    (so, se) = p.communicate()
    return p.returncode

def status_openvpn():
    """Return True if running, False if not."""
    p = Popen("service openvpn status", shell=True, stdout=PIPE, stderr=PIPE)
    (so, se) = p.communicate()
    return True if p.returncode == 0 else False

def start_openvpn():
    if DEBUG:
        print("Starting openvpn")
    p = Popen("service openvpn start", shell=True, stdout=PIPE, stderr=PIPE)
    (so, se) = p.communicate()
    return p.returncode

def update_transmission_bind_addr(addr, settings_file='/transmission/config/settings.json', try_stop_transmission=True):
    """Update the transmission settings and return True if changed."""
    result = False
    pattern = r'(.*bind-address-ipv4\"\s*:\s*\")(.*?)(\".*)'
    p = re.compile(pattern, re.DOTALL)
    with open(settings_file) as f:
        contents = f.read()
    m = p.match(contents)
    bind_ip = m.group(2)
    if bind_ip != addr:
        if try_stop_transmission and status_transmission():
            stop_transmission()
        updated_contents = m.group(1)+addr+m.group(3)
        with open(settings_file, 'w') as f:
            f.write(updated_contents)
            result = True
            if DEBUG:
                print("Updated transmission settings for %s" % addr)
    return result

def run():
    while True:
        tun_ip = get_tun_ip()
        if tun_ip is None:
            if status_transmission():
                stop_transmission()
            start_openvpn()
            # Note: check addr next iteration
        else:
            is_updated = update_transmission_bind_addr(tun_ip)
            if is_updated or not status_transmission():
                start_transmission()
            else:
                if DEBUG:
                    print("Transmission/openvpn are ok")
        time.sleep(30)

if __name__ == "__main__":
    run()
