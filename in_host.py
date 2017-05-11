#!/usr/bin/env python2.7
import sys

import json
import requests
import settings

def get_auth():
    return (settings.AUTH_NAME, settings.AUTH_PASSWORD)

def get_jail(fn_host, jail_host=None, id=None):
    if jail_host is None and id is None:
        raise ValueError("Must have one of jail_host or id args")
    jails = get_jails(fn_host)
    for jail in jails:
        if jail_host == jail['jail_host'] or id == str(jail['id']):
            return jail
    return None

def get_jails(fn_host):
    url = "http://%s/api/v1.0/jails/jails/" % (fn_host)
    jails = requests.get(url, auth=get_auth()).json()
    return jails

"""Commands"""

def cmd_add_storage(args):
    (fn_host, jail_host, source, dest) = args[0:4]
    url = "http://%s/api/v1.0/jails/mountpoints/" % (fn_host)
    data = {
        'jail': jail_host,
        'source': source,
        'destination': dest,
        'mounted': True,
    }
    response = requests.post(url, auth=get_auth(), json=data).json()
    return response

def cmd_create_jail(args):
    (fn_host, jail_host) = args[0:2]
    if get_jail(fn_host, jail_host=jail_host) is not None:
        raise ValueError("Jail '%s' already exists" % jail_host)
    url = "http://%s/api/v1.0/jails/jails/" % (fn_host)
    data = {
        'jail_host': jail_host,
        'jail_ipv4': 'DHCP',
    }
    response = requests.post(url, auth=get_auth(), json=data).json()
    return response

def cmd_test(args):
    fn_host = args[0]
    print(get_jail(fn_host, jail_host='test'))

if __name__ == '__main__':
    commands = ['test', 'create_jail', 'add_storage']
    if len(sys.argv) > 1:
        cmd_name = sys.argv[1]
        if cmd_name not in commands:
            raise ValueError("Command '%s' does not exist." % cmd_name)
        fn_args = sys.argv[2:]
        result = getattr(sys.modules[__name__], "cmd_"+cmd_name)(fn_args)
        print(result)
    else:
        raise ValueError("Missing command")
