#!/usr/local/bin/python2.7

import os
from subprocess import Popen, PIPE

def get_tun_ip():
    pipe = Popen("ifconfig tun0", shell=True, stdout=PIPE, stderr=PIPE).stdout
    x = pipe.read()
    if len(x) == 0:
        return None
    return x.split("inet ")[1].split(" ")[0]

def stop_transmission():
    pipe = Popen("service transmission stop", shell=True, stdout=PIPE, stderr=PIPE).stdout



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
