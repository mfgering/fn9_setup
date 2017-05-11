#!/usr/local/bin/python2.7
import sys

import json
import requests
import settings

######
# Commands
######

def jails(args):
    host = args[0]
    url = "http://%s/api/v1.0/jails/jails/" % (host)
    jails = requests.get(url, auth=(settings.AUTH_NAME, settings.AUTH_PASSWORD)).json()
    print(jails)
    return jails

def create_jail(args):
    (host, jail_host) = args[0:2]
    url = "http://%s/api/v1.0/jails/jails/" % (host)
    jail_data = {
        'jail_host': jail_host,
        'jail_ipv4': 'DHCP',
    }
    jail = requests.post(url, auth=(settings.AUTH_NAME, settings.AUTH_PASSWORD), json=jail_data).json()
    return jail

def test(args):
    host = args[0]
    url = "http://%s/api/v1.0/account/users/" % (host)
    x = requests.get(url, auth=(settings.AUTH_NAME, settings.AUTH_PASSWORD))
    y = x.json()
    print(x)
    print(y)

if __name__ == '__main__':

    if len(sys.argv) > 1:
        f_name = sys.argv[1]
        fn_args = sys.argv[2:]
        result = getattr(sys.modules[__name__], f_name)(fn_args)
    else:
        print("No function argument.")
