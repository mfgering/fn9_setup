#!/usr/local/bin/python2.7

import os

def get_tun_ip():
    f = os.popen('ifconfig tun0 | grep "inet\ " | cut -d: -f2 | cut -d" " -f2')
    return f.read()

def run():
    tun_ip = get_tun_ip()
    print(tun_ip)

if __name__ == "__main__":
    run()
