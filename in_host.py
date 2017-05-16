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
    response = requests.get(url, auth=get_auth()).json()
    return response


def get_mountpoints(fn_host):
    url = "http://%s/api/v1.0/jails/mountpoints/" % (fn_host)
    response = requests.get(url, auth=get_auth()).json()
    return response

def get_users(fn_host):
    url = "http://%s/api/v1.0/account/users/" % (fn_host)
    response = requests.get(url, auth=get_auth()).json()
    return response

def get_groups(fn_host):
    url = "http://%s/api/v1.0/account/groups/" % (fn_host)
    response = requests.get(url, auth=get_auth()).json()
    return response

def get_group(fn_host, group_name):
    for group in get_groups(fn_host):
        if group['bsdgrp_group'] == group_name:
            return group
    return None

"""Commands"""

def cmd_add_storage(args):
    (fn_host, jail_host, source, dest) = args[0:4]
    for mountpoint in get_mountpoints(fn_host):
        if mountpoint['destination'] == dest and mountpoint['jail'] == jail_host:
            raise ValueError("That destination already exists in jail %s." % mountpoint['jail'])
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
        'jail_autostart': True,
    }
    response = requests.post(url, auth=get_auth(), json=data).json()
    return response

def cmd_add_group(args):
    (fn_host, group_id, group_name, sudo) = args[0:5]
    url = "http://%s/api/v1.0/account/groups/" % (fn_host)
    is_sudo = True if sudo == 'sudo' else False
    group = get_group(fn_host, group_name)
    if group is not None:
        raise ValueError("Group %s already exists" % group_name)
    data = {
        'bsdgrp_gid': int(group_id),
        'bsdgrp_group': group_name,
        'bsdgrp_sudo': is_sudo,
    }
    response = requests.post(url, auth=get_auth(), json=data).json()
    return response

def cmd_add_user(args):
    (fn_host, username, full_name, password, uid, group_name, sudo) = args[0:7]
    for user in get_users(fn_host):
        if user['bsdusr_username'] == username:
            raise ValueError("User already exists")
        if str(user['bsdusr_uid']) == uid:
            raise ValueError("User ID already exists")
    url = "http://%s/api/v1.0/account/users/" % (fn_host)
    is_sudo = True if sudo == 'sudo' else False
    group = get_group(fn_host, group_name)
    if group is None:
        raise ValueError("Group %s does not exist" % group_name)
    data = {
        'bsdusr_username': username,
        'bsdusr_group': group['id'],
        'bsdusr_full_name': full_name,
        'bsdusr_password': password,
        'bsdusr_uid': int(uid),
        'bsdusr_sudo': is_sudo,
    }
    response = requests.post(url, auth=get_auth(), json=data).json()
    return response

def cmd_update_ssh_key(args):
    (fn_host, username, pub_key_file) = args[0:3]
    user_data = None
    for user in get_users(fn_host):
        if user['bsdusr_username'] == username:
            user_data = user
            break
    if user_data is None:
        raise ValueError("User %s not found" % username)
    ssh_key = open(pub_key_file).read()
    #data = user_data
    #data['bsdusr_sshpubkey'] = ssh_key
    data = {
        'bsdusr_sshpubkey': ssh_key,
    }
    url = "http://%s/api/v1.0/account/users/%d/" % (fn_host, user_data['id'])
    response = requests.put(url, auth=get_auth(), json=data).json()
    return response


def cmd_test(args):
    fn_host = args[0]
    print(get_jail(fn_host, jail_host='test'))

if __name__ == '__main__':
    commands = ['test', 'create_jail', 'add_storage', 'add_user', 'add_group',
                'update_ssh_key']
    if len(sys.argv) > 1:
        cmd_name = sys.argv[1]
        if cmd_name not in commands:
            raise ValueError("Command '%s' does not exist." % cmd_name)
        fn_args = sys.argv[2:]
        result = getattr(sys.modules[__name__], "cmd_"+cmd_name)(fn_args)
        print(result)
    else:
        raise ValueError("Missing command")
